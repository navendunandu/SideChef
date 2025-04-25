import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/recipepage.dart';

class Favorties extends StatefulWidget {
  const Favorties({super.key});

  @override
  State<Favorties> createState() => _FavortiesState();
}

class _FavortiesState extends State<Favorties> {
  List<Map<String, dynamic>> favorites = [];

  Future<void> fetchFavorite() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_favorite')
          .select("*, tbl_recipe(*)")
          .eq('user_id', uid);
          print(response);
      setState(() {
        favorites = response;
      });
    } catch (e) {
      print("Error fetching favorite recipes: $e");
    }
  }

  Future<void> deleteFavorites(int id) async {
    try {
      await supabase.from('tbl_favorite').delete().eq('id', id);
      fetchFavorite(); // Refresh list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete instruction. Try again!"),
          backgroundColor: Colors.red,
        ),
      );
      print("ERROR DELETING INSTRUCTION: $e");
    }
  }

  @override
  void initState() {
    fetchFavorite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: favorites.isEmpty
          ? Center(
              child: Text(
                "No favorites yet",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index]['tbl_recipe'] ?? {};
                int id = favorites[index]['id'];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipePage(
                                recipeId: recipe['id'].toString(),
                                isEditable: false,
                              ),
                            ),
                          );
                    
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: recipe['recipe_photo'] != null
                                  ? Image.network(
                                      recipe['recipe_photo'],
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            height: 130,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                          ),
                                    )
                                  : Container(
                                      height: 130,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                    ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.favorite, color: Color(0xFF1F7D53)),
                                onPressed: () {
                                  deleteFavorites(id);
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['recipe_name'] ?? "No Name",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.local_fire_department, size: 14, color: Color(0xFFE67E22)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${recipe['recipe_calorie'] ?? 'N/A'} cal',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined, size: 14, color: Color(0xFFE67E22)),
                                  const SizedBox(width: 4),
                                  Text(
                                    recipe['recipe_cookingtime'] ?? 'N/A',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
