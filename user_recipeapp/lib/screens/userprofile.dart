import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/followers_page.dart';
import 'package:user_recipeapp/screens/following_page.dart';
import 'package:user_recipeapp/screens/recipepage.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List<Map<String, dynamic>> recipeList = [];
  String name = '';
  String image = '';
  int followerCount = 0;
  int followingCount = 0;
  bool isFollowing = false;

  // Colors matching RecipeSearchAndSuggestionPage
  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);

  Future<void> _fetchUser() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('user_id', widget.userId)
          .single();
      setState(() {
        name = response['user_name']?.toString() ?? 'Unknown User';
        image = response['user_photo']?.toString() ?? '';
      });
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> _fetchRecipe() async {
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
          .eq('user_id', widget.userId)
          .eq('recipe_status', 1);
      setState(() {
        recipeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching recipe: $e");
    }
  }

  Future<void> _followFollowingCount() async {
    try {
      final following = await supabase
          .from('tbl_follow')
          .count()
          .eq('following_id', widget.userId);
      final followers = await supabase
          .from('tbl_follow')
          .count()
          .eq('follower_id', widget.userId);
      setState(() {
        followerCount = followers;
        followingCount = following;
      });
    } catch (e) {
      print("Error fetching follow counts: $e");
    }
  }

  Future<void> _checkFollowingStatus() async {
    try {
      final response = await supabase
          .from('tbl_follow')
          .select()
          .eq('follower_id', supabase.auth.currentUser!.id)
          .eq('following_id', widget.userId)
          .maybeSingle();
      setState(() {
        isFollowing = response != null;
      });
    } catch (e) {
      print("Error checking follow status: $e");
    }
  }

  Future<void> _toggleFollow() async {
    try {
      if (isFollowing) {
        await supabase
            .from('tbl_follow')
            .delete()
            .eq('follower_id', supabase.auth.currentUser!.id)
            .eq('following_id', widget.userId);
        setState(() {
          isFollowing = false;
          followerCount--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unfollowed successfully'),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        await supabase.from('tbl_follow').insert({
          'follower_id': supabase.auth.currentUser!.id,
          'following_id': widget.userId,
        });
        setState(() {
          isFollowing = true;
          followerCount++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Followed successfully'),
            backgroundColor: primaryColor,
          ),
        );
      }
    } catch (e) {
      print('Error toggling follow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update follow status')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRecipe();
    _fetchUser();
    _followFollowingCount();
    _checkFollowingStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$name\'s Profile',
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FollowersPage(),
                      ),
                    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FollowingPage(),
                      ),
                    );
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

            const SizedBox(height: 15),

            // Follow/Unfollow Button
            GestureDetector(
              onTap: _toggleFollow,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.grey[300] : primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  isFollowing ? 'Unfollow' : 'Follow',
                  style: TextStyle(
                    color: isFollowing ? secondaryColor : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Grid for Posts
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: recipeList.length,
                itemBuilder: (context, index) {
                  final recipe = recipeList[index];
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
            ),
          ],
        ),
      ),
    );
  }
}