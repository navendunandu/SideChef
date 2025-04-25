import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/followers_page.dart';
import 'package:user_recipeapp/screens/following_page.dart';
import 'package:user_recipeapp/screens/recipepage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> recipeList = [];
  String name = '';
  String image = '';

  // Colors matching RecipeSearchAndSuggestionPage
  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);

  Future<void> fetchUser() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        name = response['user_name']?.toString() ?? 'Unknown User';
        image = response['user_photo']?.toString() ?? '';
      });
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> fetchRecipe() async {
    try {
      final response = await supabase
          .from("tbl_recipe")
          .select('''
            id,
            recipe_name,
            recipe_photo,
            recipe_calorie,
            recipe_cookingtime,
            recipe_status
          ''')
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('recipe_status', 1);
      setState(() {
        recipeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching recipe: $e");
    }
  }

  int followerCount = 0;
  int followingCount = 0;

  Future<void> followFollowingCount() async {
    try {
      final following = await supabase
          .from('tbl_follow')
          .count()
          .eq('following_id', supabase.auth.currentUser!.id);
      final followers = await supabase
          .from('tbl_follow')
          .count()
          .eq('follower_id', supabase.auth.currentUser!.id);
      setState(() {
        followerCount = followers;
        followingCount = following;
      });
    } catch (e) {
      print("Error fetching follow counts: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecipe();
    fetchUser();
    followFollowingCount();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
            child: image.isEmpty
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),

          const SizedBox(height: 10),

          // User Name
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),

          const SizedBox(height: 10),

          // Stats Row (Posts, Followers, Following)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    recipeList.length.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const Text('Posts'),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FollowingPage(),));
                },
                child: Column(
                  children: [
                    Text(
                      followerCount.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    const Text('Followers'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FollowersPage(),));
                },
                child: Column(
                  children: [
                    Text(
                      followingCount.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    const Text('Following'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Grid for Posts
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: recipeList.length,
            itemBuilder: (context, index) {
              final recipe = recipeList[index];
              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipePage(
                        recipeId: recipe['id'].toString(),
                      ),
                    ),
                  );
                  if (result == true) {
                    fetchRecipe();
                  }
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
                            child: recipe['recipe_photo'] != null &&
                                    recipe['recipe_photo'].isNotEmpty
                                ? Image.network(
                                    recipe['recipe_photo'],
                                    height: 130,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 130,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
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
                              recipe['recipe_name'] ?? 'Unnamed',
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
                                Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${recipe['recipe_calorie'] ?? 'N/A'} cal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: accentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      recipe['recipe_cookingtime'] ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}
