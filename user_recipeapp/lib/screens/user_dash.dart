import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/recipepage.dart';
import 'package:user_recipeapp/screens/userprofile.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {

  bool isLoading = false;

  List<Map<String, dynamic>> reciepeList = [];
  List<Map<String, dynamic>> recentList = [];

  Future<void> fetchRecipie() async {
  try {
    setState(() {
      isLoading = true;
    });

    String uid = supabase.auth.currentUser!.id; // Get logged-in user ID
    print("Current User ID: $uid"); // Debugging

    final response = await supabase
        .from('tbl_recipe')
        .select()
        .neq('user_id', uid).eq('recipe_status', 1);

    print("Fetched Recipes: $response"); // Debugging

    setState(() {
      isLoading = false;
      reciepeList = response;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print("Error fetching recipes: $e");
  }
}
  List<Map<String, dynamic>> userList = [];

  Future<void> fetchUser() async {
    try {
      final response = await supabase.from('tbl_user').select().neq('user_id', supabase.auth.currentUser!.id);
      setState(() {
        userList = response;
      });
      print(response);
    } catch (e) {
      print("Error: $e");
      
    }
  }

  Future<void> fetchRecent() async {
    try {
      final response = await supabase.from('tbl_recent').select("*,tbl_recipe(*)").eq('user_id', supabase.auth.currentUser!.id).order('updated_at', ascending: false);
      setState(() {
        recentList=response;
      });
    } catch (e) {
      print("Error: $e");
      
    } 
  }

  @override
  void initState() {
    fetchRecipie();
    fetchUser();
    fetchRecent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(

      child: CircularProgressIndicator(),
    ) : Column(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trending Recipes
        const Text(
          "Trending Recipes",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: Builder(
            builder: (context) {
              // Shuffle only once
              List<Map<String, dynamic>> shuffledRecipes = List.from(reciepeList)..shuffle();
              int trendingCount = shuffledRecipes.length < 3 ? shuffledRecipes.length : 3;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trendingCount,
                itemBuilder: (context, index) {
                  final recipe = shuffledRecipes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RecipePage(recipeId: recipe['id'].toString(),isEditable: false,),));
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                        image: DecorationImage(image: NetworkImage(recipe['recipe_photo']),fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Popular Categories
        const Text(
          "Popular Recipies",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: reciepeList.length,
          itemBuilder: (context, index) {
            final recipe = reciepeList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RecipePage(recipeId: recipe['id'].toString(),isEditable: false,),));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300], // Placeholder color
                    image: DecorationImage(image: NetworkImage(recipe['recipe_photo']),fit: BoxFit.cover),
                  ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Follow Creators
        const Text(
          "Follow Creators",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: userList.length, // Placeholder count
            itemBuilder: (context, index) {
              final data = userList[index];
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userId: data['user_id'],),));
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[300],
                    image:  data['user_photo'] != null ? DecorationImage(image: NetworkImage(data['user_photo']),fit: BoxFit.cover) : null,
                    // Placeholder color
                  ),
                  child: data['user_photo'] == null ? const Center(
                    child: Icon(Icons.person, color: Colors.white),
                  ): null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Recently Viewed Recipes
        const Text(
          "Recently Viewed Recipes",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentList.length,
            itemBuilder: (context, index) {
              final data = recentList[index]['tbl_recipe'];
              return GestureDetector(
                 onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RecipePage(recipeId: data['id'].toString(),isEditable: false,),));
              },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(image: NetworkImage(data['recipe_photo']),fit: BoxFit.cover),
                    color: Colors.pink[200], // Placeholder color
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
