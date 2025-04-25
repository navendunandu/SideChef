import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({super.key});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      var query = supabase
          .from('tbl_recipe')
          .select()
          .eq('recipe_status', 1) // Filter for active recipes
          .order('created_at', ascending: false);

      final response = await query;
      print("Recipes response: $response");
      if (mounted) {
        setState(() {
          recipes = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching recipes: $e')),
        );
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          'Recipe List',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFA5D6A7).withOpacity(0.2),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipe List',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A3C34),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View all active recipes',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: recipes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.restaurant_menu,
                                      size: 80, color: Colors.grey[400]),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No active recipes found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Recipe details on the left
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe['recipe_name'] ?? 'No Name',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: const Color(0xFF1A3C34),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.local_dining,
                                                      size: 14, color: const Color(0xFF2E7D32)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    recipe['recipe_calorie'] != null
                                                        ? '${recipe['recipe_calorie']} cal'
                                                        : 'N/A',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.category,
                                                      size: 14, color: const Color(0xFF2E7D32)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    recipe['recipie_type'] != null
                                                        ? recipe['recipie_type'].toString()
                                                        : 'N/A',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.star_border,
                                                      size: 14, color: const Color(0xFF2E7D32)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    recipe['level_id'] != null
                                                        ? recipe['level_id'].toString()
                                                        : 'N/A',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.flag,
                                                      size: 14, color: const Color(0xFF2E7D32)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    recipe['cuisine_id'] != null
                                                        ? recipe['cuisine_id'].toString()
                                                        : 'N/A',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.timer,
                                                      size: 14, color: const Color(0xFF2E7D32)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    recipe['recipe_cookingtime'] != null
                                                        ? '${recipe['recipe_cookingtime']} min'
                                                        : 'N/A',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today,
                                                      size: 14, color: const Color(0xFF2E7D32)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    recipe['created_at']
                                                            ?.toString()
                                                            .substring(0, 10) ??
                                                        'N/A',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (recipe['recipe_status'] != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.check_circle,
                                                          size: 14,
                                                          color: const Color(0xFF2E7D32)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        recipe['recipe_status'] == 1
                                                            ? 'Active'
                                                            : 'Inactive',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.grey[800],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (recipe['recipe_id'] != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.label,
                                                          size: 14,
                                                          color: const Color(0xFF2E7D32)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'ID: ${recipe['recipe_id']}',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.grey[800],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Image on the right
                                        if (recipe['recipe_photo'] != null &&
                                            recipe['recipe_photo'].toString().isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.only(left: 16),
                                            width: 100,
                                            height: 100,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                recipe['recipe_photo'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(Icons.image_not_supported,
                                                          color: Colors.grey),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
