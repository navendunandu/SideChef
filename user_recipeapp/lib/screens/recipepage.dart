import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/addcomment.dart';
import 'package:user_recipeapp/screens/homepage.dart';
import 'package:user_recipeapp/screens/profile.dart';

class RecipePage extends StatefulWidget {
  final String recipeId;
  final bool isEditable;
  const RecipePage({super.key, required this.recipeId, this.isEditable = true});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Map<String, dynamic>? recipe;
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> steps = [];
  List<Map<String, dynamic>> comments = [];
  double averageRating = 0.0;
  int servingSize = 1; // Default serving size
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
    fetchComments();
    recentView();
  }

  Future<void> insertFavorite() async {
    try {
      print("recipe_id: ${widget.recipeId}");
      final response = await supabase
          .from('tbl_favorite')
          .select()
          .eq('recipe_id', widget.recipeId)
          .eq('user_id',
              supabase.auth.currentUser!.id) // Use null-aware operator
          .maybeSingle();
      if (response != null) {
        await supabase.from('tbl_favorite').delete().eq('id', response['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe removed from favorites!'),
          ),
        );
      } else {
        await supabase.from('tbl_favorite').insert({
          'recipe_id': widget.recipeId,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe added to favorites!'),
          ),
        );
      }
    } catch (e) {
      print("Error fav: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to favorites: $e'),
        ),
      );
    }
  }

  Future<void> recentView() async {
    try {
      print("Recent updated");
      await supabase.from('tbl_recent').upsert(
        {
          'recipe_id': widget.recipeId,
          'user_id': supabase.auth.currentUser!.id,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'recipe_id,user_id', // Specify the unique constraint
      );
      print("Recent view updated successfully");
    } catch (e) {
      print("Error adding/updating recent: $e");
    }
  }

  Future<bool?> deleteConfirm() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text('Confirm Deletion'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${recipe?['recipe_name']}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Example method to delete a recipe (to be called from RecipePage or elsewhere)
  Future<void> _deleteRecipe() async {
    bool? confirm = await deleteConfirm();
    if (confirm == true) {
      try {
        await supabase.from("tbl_comment").delete().eq('recipe_id', widget.recipeId);
        await supabase.from("tbl_favorite").delete().eq('recipe_id', widget.recipeId);
        await supabase.from("tbl_recent").delete().eq('recipe_id', widget.recipeId);
        await supabase.from("tbl_ingredient").delete().eq('reciepe_id', widget.recipeId);
        await supabase.from("tbl_instructions").delete().eq('recipe_id', widget.recipeId);

        await supabase.from('tbl_recipe').delete().eq('id', widget.recipeId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe deleted successfully')),
        );
        Navigator.pop(context, true); // Go back to previous screen
      } catch (e) {
        print('Error deleting recipe: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete recipe')),
        );
      }
    }
  }

  bool isFavorite = false; // Track favorite status

  Future<void> checkIfFavorite() async {
    try {
      final response = await supabase
          .from('tbl_favorite')
          .select()
          .eq('recipe_id', widget.recipeId)
          .eq('user_id', supabase.auth.currentUser!.id)
          .maybeSingle();

      setState(() {
        isFavorite = response != null; // If response exists, it's a favorite
      });
    } catch (e) {
      print("Error checking favorite: $e");
    }
  }

  Future<void> fetchRecipeDetails() async {
    try {
      final response = await supabase
          .from('tbl_recipe')
          .select(
              '*, tbl_user(user_name), tbl_ingredient(*, tbl_item(item_name)), tbl_instructions(*)')
          .eq('id', widget.recipeId)
          .single();

      setState(() {
        recipe = response;
        ingredients =
            List<Map<String, dynamic>>.from(response['tbl_ingredient'] ?? []);
        steps =
            List<Map<String, dynamic>>.from(response['tbl_instructions'] ?? []);
        servingSize = recipe?['serving_size'] ?? 1;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipe: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchComments() async {
    try {
      // Fetch comments with user information
      final response = await supabase
          .from('tbl_comment')
          .select('*, tbl_user(user_name, user_photo)')
          .eq('recipe_id', widget.recipeId)
          .order('comment_date', ascending: false);

      // Calculate average rating
      final ratingResponse = await supabase
          .from('tbl_comment')
          .select('comment_ratingvalue')
          .eq('recipe_id', widget.recipeId);

      double totalRating = 0;
      int ratingCount = 0;

      for (var rating in ratingResponse) {
        if (rating['comment_ratingvalue'] != null) {
          totalRating += rating['comment_ratingvalue'];
          ratingCount++;
        }
      }

      setState(() {
        comments = List<Map<String, dynamic>>.from(response);
        averageRating = ratingCount > 0 ? totalRating / ratingCount : 0;
      });
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

//   void _shareRecipe(Map<String, dynamic> recipe) {
//     final String shareText = '''
// Recipe: ${recipe['recipe_name'] ?? 'Unnamed Recipe'}
// Calories: ${recipe['recipe_calorie'] ?? 'N/A'}
// Cooking Time: ${recipe['recipe_cookingtime'] ?? 'N/A'}
// Type: ${recipe['recipie_type'] ?? 'N/A'}
// Cuisine: ${recipe['tbl_cuisine']?['cuisine_name'] ?? 'N/A'}
// Category: ${recipe['tbl_category']?['category_name'] ?? 'N/A'}
// Level: ${recipe['tbl_level']?['level_name'] ?? 'N/A'}
// Photo: ${recipe['recipe_photo'] ?? 'No photo available'}
// ''';

//     Share.share(
//       shareText,
//       subject: 'Check out this recipe!',
//     );
//   }

  // Widget to display star rating
  Widget buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? const Color(0xFF1F7D53) : Colors.grey,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1F7D53),
          ),
        ),
      );
    }

    if (recipe == null) {
      return const Scaffold(
        body: Center(child: Text("Recipe not found")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Recipe Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          widget.isEditable
              ? PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == "Delete") {
                      _deleteRecipe();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: "Delete",
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_outlined,
                                color: Color.fromARGB(255, 0, 0, 0)),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 100, // Adjust width as needed
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                )
              : Container(),
        ],
      ),
      floatingActionButton: !widget.isEditable
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddComment(
                      recipeId: int.parse(widget.recipeId),
                    ),
                  ),
                ).then((_) => fetchComments()); // Refresh comments after adding
              },
              backgroundColor: const Color(0xFF1F7D53),
              child: const Icon(Icons.rate_review, color: Colors.white),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    recipe?['recipe_photo'] ?? '',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      onPressed: () {
                        insertFavorite();
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Recipe Name & Username (Clickable)
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(),
                    ));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      recipe?['recipe_name'] ?? 'Unknown Recipe',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      "by ${recipe?['tbl_user']?['user_name'] ?? 'Unknown Chef'}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Rating & Cooking Time
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F7D53).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer,
                          color: Color(0xFF1F7D53), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${recipe?['recipe_cookingtime'] ?? 'N/A'}",
                        style: const TextStyle(
                          color: Color(0xFF1F7D53),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F7D53).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFF1F7D53), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF1F7D53),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Ingredients & Serving Size
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ingredients",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text("Serving Size: "),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Color(0xFF1F7D53)),
                      onPressed: servingSize > 1
                          ? () {
                              setState(() {
                                servingSize--;
                              });
                            }
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1F7D53)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        servingSize.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Color(0xFF1F7D53)),
                      onPressed: () {
                        setState(() {
                          servingSize++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: ingredients.map((ingredient) {
                  return ListTile(
                    title: Text(
                      ingredient['tbl_item']?['item_name'] ?? 'Unknown Item',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      "${((ingredient['ingredient_quantity'] ?? 1) * servingSize).toString()} ${ingredient['ingredient_unit'] ?? ''}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Steps
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step-by-step mode button (optional)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F7D53),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "INSTRUCTIONS",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Steps
                  Column(
                    children: steps.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      Map<String, dynamic> step = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Step $index",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['ingredient_instructions'] ??
                                'No instructions available',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Divider
                          Divider(
                            color: Colors.grey[200],
                            thickness: 2,
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reviews Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Reviews & Comments",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (!widget.isEditable)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddComment(
                                recipeId: int.parse(widget.recipeId),
                              ),
                            ),
                          ).then((_) => fetchComments());
                        },
                        icon: const Icon(Icons.add, color: Color(0xFF1F7D53)),
                        label: const Text(
                          "Add",
                          style: TextStyle(color: Color(0xFF1F7D53)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Average Rating Display (optional, keep if you want)
                if (comments.any((c) => (c['comment_ratingvalue'] ?? 0) > 0))
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F7D53).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F7D53),
                              ),
                            ),
                            buildRatingStars(averageRating),
                            Text(
                              "${comments.where((c) => (c['comment_ratingvalue'] ?? 0) > 0).length} ${comments.length == 1 ? 'review' : 'reviews'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              _buildRatingBar(5, comments),
                              _buildRatingBar(4, comments),
                              _buildRatingBar(3, comments),
                              _buildRatingBar(2, comments),
                              _buildRatingBar(1, comments),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Show all comments and reviews together
                comments.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No comments or reviews yet",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Be the first to comment or review this recipe",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: comments.map((comment) {
                          return _buildReviewCard(comment);
                        }).toList(),
                      ),
              ],
            ),

            const SizedBox(height: 16),

            // Done Button (if editable)
            widget.isEditable
                ? Center(
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: const BorderSide(color: Colors.black),
                          ),
                          minimumSize: const Size(double.infinity, 15),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  // Helper method to build rating distribution bars
  Widget _buildRatingBar(int rating, List<Map<String, dynamic>> comments) {
    int count = comments
        .where((comment) => comment['comment_ratingvalue'] == rating)
        .length;

    double percentage = comments.isNotEmpty ? count / comments.length : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            "$rating",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F7D53),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "$count",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Helper method to build a review card
  Widget _buildReviewCard(Map<String, dynamic> comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and rating
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: comment['tbl_user']?['user_photo'] != null
                      ? NetworkImage(comment['tbl_user']['user_photo'])
                      : null,
                  child: comment['tbl_user']?['user_photo'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                // Username and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['tbl_user']?['user_name'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(comment['comment_date']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                buildRatingStars(
                  (comment['comment_ratingvalue'] ?? 0).toDouble(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Comment content
            if (comment['comment_content'] != null &&
                comment['comment_content'].toString().isNotEmpty)
              Text(
                comment['comment_content'],
                style: const TextStyle(fontSize: 14),
              ),

            // Comment photo (if any)
            if (comment['comment_photo'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    comment['comment_photo'],
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to format date
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}
