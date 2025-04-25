import 'package:admin_recipeapp/screens/login.dart';
import 'package:admin_recipeapp/screens/recipelist.dart';
import 'package:admin_recipeapp/screens/userlist.dart';
import 'package:admin_recipeapp/screens/category.dart';
import 'package:admin_recipeapp/screens/complaints.dart';
import 'package:admin_recipeapp/screens/cuisine.dart';
import 'package:admin_recipeapp/screens/dashboard.dart';
import 'package:admin_recipeapp/screens/diet.dart';
import 'package:admin_recipeapp/screens/ingredient.dart';
import 'package:admin_recipeapp/screens/level.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
      routes: {
        '/login': (context) => const Login(), // Ensure this matches the Login widget
      },
      onUnknownRoute: (settings) {
        // Fallback for undefined routes
        debugPrint('Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
      },
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  final List<String> pageNames = [
    'Dashboard',
    'Category',
    'Level',
    'Ingredient',
    'Cuisine',
    'Diet',
    'User List',
    'Recipe List',
    'Complaints',
  ];

  final List<IconData> pageIcons = [
    Icons.dashboard,
    Icons.category,
    Icons.star,
    Icons.soup_kitchen,
    Icons.restaurant,
    Icons.restaurant_menu,
    Icons.person,
    Icons.list,
    Icons.file_copy,
  ];

  final List<Widget> pageContent = [
    const Dashboard(),
    const CategoryPage(),
    const LevelPage(),
    const Ingredient(),
    const Cuisine(),
    const Diet(),
    const Userlist(),
    const RecipeList(),
    const Complaints(),
  ];

  // Function to clear session data
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('Session cleared successfully');
    } catch (e) {
      debugPrint('Error clearing session: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: $e')),
        );
      }
    }
  }

  // Logout function
  Future<void> _logout() async {
    debugPrint('Logout initiated');

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    debugPrint('shouldLogout: $shouldLogout');

    if (shouldLogout ?? false) {
      await _clearSession();

      if (mounted) {
        debugPrint('Navigating to login screen');
        try {
          Navigator.of(context).pushReplacementNamed('/login');
        } catch (e) {
          debugPrint('Navigation error: $e');
          // Fallback navigation
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      } else {
        debugPrint('Widget not mounted, using microtask');
        Future.microtask(() {
          Navigator.of(context).pushReplacementNamed('/login');
        });
      }
    } else {
      debugPrint('Logout cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageNames[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white.withOpacity(0.9),
            ),
            onPressed: _logout,
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF1A3C34),
            unselectedIconTheme:
                IconThemeData(color: Colors.white.withOpacity(0.7)),
            unselectedLabelTextStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            selectedIconTheme: const IconThemeData(color: Color(0xFFA5D6A7)),
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFFA5D6A7),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            destinations: List.generate(pageNames.length, (index) {
              return NavigationRailDestination(
                icon: Icon(pageIcons[index]),
                selectedIcon: Icon(pageIcons[index]),
                label: Text(pageNames[index]),
              );
            }),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFFF1F8E9),
              padding: const EdgeInsets.all(20),
              child: pageContent[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}