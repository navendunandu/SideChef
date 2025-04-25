import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart'; // Import your main.dart file for Supabase
import 'package:user_recipeapp/screens/homepage.dart';
import 'package:user_recipeapp/screens/profile.dart';
import 'package:user_recipeapp/screens/userprofile.dart'; // Import profile screen

class ViewRecipe extends StatefulWidget {
  final int recipeId;
  const ViewRecipe({super.key, required this.recipeId});

  @override
  State<ViewRecipe> createState() => _ViewRecipeState();
}

class _ViewRecipeState extends State<ViewRecipe> {
  Map<String, dynamic>? recipe;
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> steps = [];
  int servingSize = 1; // Default serving size
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    try {
      print("Fetching recipe details. ID: ${widget.recipeId}");
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recipe == null) {
      return const Scaffold(
        body: Center(
          child: Text("Recipe not found"),
        ),
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
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == "Delete") {
                // Handle delete action
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                recipe?['recipe_photo'] ?? '',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),

            // Recipe Name & Username (Clickable)
            Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Center(
      child: Text(
        recipe?['recipe_name'] ?? 'Unknown Recipe',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
   Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Center(
      child: Text(
        recipe?['recipe_name'] ?? 'Unknown Recipe',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
    Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Center(
      child: Text(
        recipe?['recipe_name'] ?? 'Unknown Recipe',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
    Center(
      child: GestureDetector(
        onTap: () {
          // Navigate to the author's profile using their user_id
          final authorId = recipe?['tbl_user']?['user_id'] ?? 'unknown'; // Ensure this matches your data structure
          if (authorId != 'unknown') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(userId: authorId),
              ),
            );
          }
        },
        child: Text(
          "by ${recipe?['tbl_user']?['user_name'] ?? 'Unknown Chef'}",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    ),
  ],
),
  ],
),
  ],
),

            const SizedBox(height: 10),

            // Rating & Cooking Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(" ${recipe?['recipe_cookingtime'] ?? 0} "),
              ],
            ),

            const SizedBox(height: 10),

            // Ingredients & Serving Size
            Text("Ingredients",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Text("Serving Size: "),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: servingSize > 1
                      ? () {
                          setState(() {
                            servingSize--;
                          });
                        }
                      : null,
                ),
                Text(servingSize.toString()),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      servingSize++;
                    });
                  },
                ),
              ],
            ),
            Column(
              children: ingredients.map((ingredient) {
                return ListTile(
                  title: Text(
                      ingredient['tbl_item']?['item_name'] ?? 'Unknown Item'),
                  trailing: Text(
                    "${((ingredient['ingredient_quantity'] ?? 1) * servingSize).toString()} ${ingredient['ingredient_unit'] ?? ''}",
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // Steps
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    221, 255, 255, 255), // Dark background like your image
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step-by-step mode button (optional)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
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
                            style: const TextStyle(
                              color: Colors.grey, // Step number in grey
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['ingredient_instructions'] ??
                                'No instructions available',
                            style: const TextStyle(
                              color: Color.fromARGB(
                                  255, 8, 8, 8), // White text like your image
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Dotted Divider (like your image)
                          Divider(
                            color: const Color.fromARGB(255, 227, 225, 211),
                            thickness: 3,
                            indent: 10,
                            endIndent: 10,
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
           Center(
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
                   backgroundColor: Colors.white, // White background
                   padding: const EdgeInsets.symmetric(vertical: 5), // Makes it taller
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.zero, // Makes it a perfect rectangle
                     side: BorderSide(color: Colors.black), // Optional: Black border for better visibility
                   ),
                   minimumSize: const Size
                   (double.infinity, 15
                   ), // Full width, adjust height as needed
                 ),
                 child: const Text(
                   'DONE',
                   style: TextStyle(
                     color: Colors.black, // Black text for contrast
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),
           )

          ],
        ),
      ),
    );
  }
}
