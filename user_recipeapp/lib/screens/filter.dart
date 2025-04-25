import 'package:flutter/material.dart';

class RecipeSearchPage extends StatefulWidget {
  const RecipeSearchPage({super.key});

  @override
  State<RecipeSearchPage> createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  final TextEditingController searchController = TextEditingController();

  // Dropdown selections
  String? selectedCuisine;
  String? selectedCategory;
  String? selectedDiet;
  String? selectedLevel;

  // Slider values
  double maxCookingTime = 60; // Default max time in minutes
  double minRating = 3; // Default min rating
  double maxCalories = 500; // Default max calories

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Recipes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search recipes...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cuisine Dropdown
            DropdownButtonFormField<String>(
              value: selectedCuisine,
              items: ["Italian", "Chinese", "Indian", "Mexican"] // Sample data
                  .map((cuisine) => DropdownMenuItem(
                        value: cuisine,
                        child: Text(cuisine),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCuisine = value;
                });
              },
              decoration: const InputDecoration(labelText: "Cuisine"),
            ),

            const SizedBox(height: 10),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: ["Vegetarian", "Non-Vegetarian", "Dessert"] // Sample data
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 10),

            // Diet Plan Dropdown
            DropdownButtonFormField<String>(
              value: selectedDiet,
              items: ["Keto", "Vegan", "Paleo"] // Sample data
                  .map((diet) => DropdownMenuItem(
                        value: diet,
                        child: Text(diet),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDiet = value;
                });
              },
              decoration: const InputDecoration(labelText: "Diet Plan"),
            ),

            const SizedBox(height: 10),

            // Difficulty Level Dropdown
            DropdownButtonFormField<String>(
              value: selectedLevel,
              items: ["Easy", "Moderate", "Hard"]
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedLevel = value;
                });
              },
              decoration: const InputDecoration(labelText: "Difficulty Level"),
            ),

            const SizedBox(height: 16),

            // Cooking Time Filter (Slider)
            Text("Max Cooking Time: ${maxCookingTime.round()} min"),
            Slider(
              value: maxCookingTime,
              min: 10,
              max: 120,
              divisions: 11,
              label: "${maxCookingTime.round()} min",
              onChanged: (value) {
                setState(() {
                  maxCookingTime = value;
                });
              },
            ),

            // Rating Filter (Slider)
            Text("Min Rating: ${minRating.toStringAsFixed(1)}"),
            Slider(
              value: minRating,
              min: 0,
              max: 5,
              divisions: 5,
              label: minRating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  minRating = value;
                });
              },
            ),

            // Calories Filter (Slider)
            Text("Max Calories: ${maxCalories.round()} kcal"),
            Slider(
              value: maxCalories,
              min: 100,
              max: 1000,
              divisions: 9,
              label: "${maxCalories.round()} kcal",
              onChanged: (value) {
                setState(() {
                  maxCalories = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Search Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _performSearch();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Search",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle search logic
  void _performSearch() {
    String keyword = searchController.text.trim();
    
    print("Searching for: $keyword");
    print("Cuisine: $selectedCuisine");
    print("Category: $selectedCategory");
    print("Diet: $selectedDiet");
    print("Difficulty Level: $selectedLevel");
    print("Max Cooking Time: ${maxCookingTime.round()} min");
    print("Min Rating: $minRating");
    print("Max Calories: ${maxCalories.round()} kcal");

    // TODO: Implement search logic (query from Supabase and update results)
  }
}
