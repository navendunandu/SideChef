import 'package:flutter/material.dart';
import 'package:user_recipeapp/screens/analytics.dart';
import 'package:user_recipeapp/screens/change_password.dart';
import 'package:user_recipeapp/screens/createrecipe.dart';
import 'package:user_recipeapp/screens/editprofile.dart';
import 'package:user_recipeapp/screens/favorties.dart';
import 'package:user_recipeapp/screens/profile.dart';
import 'package:user_recipeapp/screens/recipie_suggestion.dart';
import 'package:user_recipeapp/screens/user_complaints.dart';
import 'package:user_recipeapp/screens/user_dash.dart';
// Assuming you have a login screen
import 'package:user_recipeapp/screens/login.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);
  final Color backgroundColor = const Color(0xFFF9F9F9);

  List<Map<String, dynamic>> pages = [
    {'label': "Home", 'icon': Icons.home, 'page': UserDashboard()},
    {'label': "Recipe", 'icon': Icons.restaurant_menu, 'page': RecipeSearchAndSuggestionPage()},
    {
      'label': "Add Recipe",
      'icon': Icons.add_circle_outline_sharp,
      'page': Createrecipe()
    },
    {
      'label': "Favorites",
      'icon': Icons.favorite,
      'page': Favorties()
    },
    {
      'label': "Profile",
      'icon': Icons.person_outline_outlined,
      'page': Profile()
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  // Add logout function
  void _logout() {
    // Here you would typically:
    // 1. Clear any user authentication tokens
    // 2. Clear stored user data
    // 3. Navigate to login screen
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()), // Replace with your actual login screen
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex != 1 ? AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: _selectedIndex == 4 ? Text("SideChef") : const Text(
          "Find Best Recipes for Cooking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        // ...existing code...
actions: [
  _selectedIndex == 4
      ? PopupMenuButton<int>(
          color: Colors.white, // Set menu background to pure white
          padding: EdgeInsets.symmetric(horizontal: 10),
          popUpAnimationStyle: AnimationStyle(
            curve: Curves.easeInQuint,
            reverseCurve: Curves.easeOutQuint,
          ),
          icon: Icon(Icons.more_vert_outlined, color: Colors.black), // Optional: set icon color
          itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.black87),
                  title: Text("Profile", style: TextStyle(color: Colors.black87)),
                  onTap: () async {
                    Navigator.pop(context); // Close the menu
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfile()));
                    if (result == true) {
                      setState(() {});
                    }
                  },
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.lock, color: Colors.black87),
                  title: Text("Change Password", style: TextStyle(color: Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ChangePasswordPage()));
                  },
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.report_problem, color: Colors.black87),
                  title: Text("Complaints", style: TextStyle(color: Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ComplaintsPage()));
                  },
                ),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: ListTile(
                  leading: Icon(Icons.analytics, color: Colors.black87),
                  title: Text("Analytics", style: TextStyle(color: Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AnalyticsPage()));
                  },
                ),
              ),
              PopupMenuItem<int>(
                value: 4,
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text("Logout", style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
              ),
            ];
          },
        )
      : SizedBox()
],
// ...existing code...
      ) : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: pages[_selectedIndex]['page']),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(pages.length, (index) {
                final isSelected = _selectedIndex == index;
                final isCreateButton = index == 2;
                
                if (isCreateButton) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        pages[index]['icon'],
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                }
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          pages[index]['icon'],
                          color: isSelected ? primaryColor : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pages[index]['label'],
                        style: TextStyle(
                          color: isSelected ? primaryColor : Colors.grey,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}