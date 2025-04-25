import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_recipeapp/screens/recipepage.dart';

class RecipeSearchAndSuggestionPage extends StatefulWidget {
  const RecipeSearchAndSuggestionPage({super.key});

  @override
  State<RecipeSearchAndSuggestionPage> createState() =>
      _RecipeSearchAndSuggestionPageState();
}

class _RecipeSearchAndSuggestionPageState
    extends State<RecipeSearchAndSuggestionPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ingredientSearchController =
      TextEditingController();

  // Search-related state
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  String? _selectedFilterType;
  String? _selectedCategory;
  String? _selectedCuisine;
  String? _selectedLevel;
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> cuisineList = [];
  List<Map<String, dynamic>> levelList = [];

  // Ingredient selection state
  List<Map<String, dynamic>> items = [];
  Set<int> selectedItemIds = {};
  String ingredientSearchQuery = "";

  // UI state
  bool _isLoading = true;

  // Colors
  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _fetchCategories();
    _fetchCuisines();
    _fetchLevels();
    _fetchItems();
    _searchController.addListener(_filterRecipes);
    _ingredientSearchController.addListener(() => setState(() {
          ingredientSearchQuery = _ingredientSearchController.text;
        }));
  }

 Future<void> _fetchRecipes() async {
  setState(() => _isLoading = true);
  try {
    final response = await supabase
        .from('tbl_recipe')
        .select('''
          id,
          recipe_name,
          recipe_photo,
          recipe_calorie,
          recipe_cookingtime,
          recipie_type,
          category_id,
          cuisine_id,
          level_id,
          tbl_category (category_name),
          tbl_cuisine (cuisine_name),
          tbl_level (level_name)
        ''')
        .eq('recipe_status', 1); // Add this line to filter by recipe_status = 1
    setState(() {
      recipes = List<Map<String, dynamic>>.from(response);
      filteredRecipes = recipes;
      _isLoading = false;
    });
  } catch (e) {
    print('Error fetching recipes: $e');
    setState(() => _isLoading = false);
  }
}

  Future<void> _fetchCategories() async {
    final response = await supabase.from('tbl_category').select();
    setState(() => categoryList = List<Map<String, dynamic>>.from(response));
  }

  Future<void> _fetchCuisines() async {
    final response = await supabase.from('tbl_cuisine').select();
    setState(() => cuisineList = List<Map<String, dynamic>>.from(response));
  }

  Future<void> _fetchLevels() async {
    final response = await supabase.from('tbl_level').select();
    setState(() => levelList = List<Map<String, dynamic>>.from(response));
  }

  Future<void> _fetchItems() async {
    final response = await supabase.from('tbl_item').select();
    setState(() => items = List<Map<String, dynamic>>.from(response));
  }

  void _filterRecipes() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredRecipes = recipes.where((recipe) {
        final name = recipe['recipe_name']?.toString().toLowerCase() ?? '';
        final matchesSearch = name.contains(query);
        final matchesType = _selectedFilterType == null ||
            recipe['recipie_type'] == _selectedFilterType;
        final matchesCategory = _selectedCategory == null ||
            recipe['category_id'].toString() == _selectedCategory;
        final matchesCuisine = _selectedCuisine == null ||
            recipe['cuisine_id'].toString() == _selectedCuisine;
        final matchesLevel = _selectedLevel == null ||
            recipe['level_id'].toString() == _selectedLevel;
        return matchesSearch &&
            matchesType &&
            matchesCategory &&
            matchesCuisine &&
            matchesLevel;
      }).toList();

      if (selectedItemIds.isNotEmpty) {
        _filterByIngredients();
      }
    });
  }

  void _filterByIngredients() async {
    if (selectedItemIds.isEmpty) return;

    final ingredientResponse =
        await supabase.from('tbl_ingredient').select('reciepe_id, item_id');
    Map<int, Set<int>> recipeIngredients = {};
    for (var row in ingredientResponse) {
      int recipeId = int.parse(row['reciepe_id'].toString());
      int itemId = int.parse(row['item_id'].toString());
      recipeIngredients.putIfAbsent(recipeId, () => {}).add(itemId);
    }

    Set<int> validRecipeIds = recipeIngredients.entries
        .where((entry) => selectedItemIds.containsAll(entry.value))
        .map((entry) => entry.key)
        .toSet();

    setState(() {
      filteredRecipes = filteredRecipes
          .where((recipe) => validRecipeIds.contains(recipe['id']))
          .toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedFilterType = null;
      _selectedCategory = null;
      _selectedCuisine = null;
      _selectedLevel = null;
      selectedItemIds.clear();
      _searchController.clear();
      _ingredientSearchController.clear();
      ingredientSearchQuery = "";
      _filterRecipes();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Recipes',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSection('Recipe Type', [
                RadioListTile<String?>(
                    title: const Text('Veg'),
                    value: 'Veg',
                    groupValue: _selectedFilterType,
                    onChanged: (v) =>
                        _updateFilter(() => _selectedFilterType = v),
                    activeColor: primaryColor),
                RadioListTile<String?>(
                    title: const Text('Non-Veg'),
                    value: 'Non-Veg',
                    groupValue: _selectedFilterType,
                    onChanged: (v) =>
                        _updateFilter(() => _selectedFilterType = v),
                    activeColor: primaryColor),
                RadioListTile<String?>(
                    title: const Text('All'),
                    value: null,
                    groupValue: _selectedFilterType,
                    onChanged: (v) =>
                        _updateFilter(() => _selectedFilterType = v),
                    activeColor: primaryColor),
              ]),
              _buildDropdownFilter('Category', _selectedCategory, categoryList,
                  'category_name', (v) => _selectedCategory = v),
              _buildDropdownFilter('Cuisine', _selectedCuisine, cuisineList,
                  'cuisine_name', (v) => _selectedCuisine = v),
              _buildDropdownFilter('Level', _selectedLevel, levelList,
                  'level_name', (v) => _selectedLevel = v),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                _resetFilters();
                Navigator.pop(context);
              },
              child: Text('Reset', style: TextStyle(color: accentColor))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _filterRecipes();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showIngredientSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Create a local copy of selected items to modify within the dialog
        Set<int> tempSelectedItemIds = Set.from(selectedItemIds);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Map<String, dynamic>> filteredItems = items
                .where((item) => item['item_name']
                    .toLowerCase()
                    .contains(ingredientSearchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              title: const Text('Select Ingredients',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 400, // Fixed height for the dialog content
                child: Column(
                  children: [
                    TextField(
                      controller: _ingredientSearchController,
                      decoration: InputDecoration(
                        hintText: "Search for items",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredItems.map((item) {
                            return ChoiceChip(
                              label: Text(
                                item['item_name'],
                                style: TextStyle(
                                  color:
                                      tempSelectedItemIds.contains(item['id'])
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                              selected:
                                  tempSelectedItemIds.contains(item['id']),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    tempSelectedItemIds.add(item['id']);
                                  } else {
                                    tempSelectedItemIds.remove(item['id']);
                                  }
                                });
                              },
                              selectedColor: primaryColor,
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedItemIds = tempSelectedItemIds;
                      _filterRecipes();
                    });
                    Navigator.pop(context);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('Apply',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: secondaryColor)),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownFilter(
      String title,
      String? value,
      List<Map<String, dynamic>> items,
      String displayKey,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: secondaryColor)),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text('Select $title'),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('All')),
            ...items.map((item) => DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(item[displayKey] ?? '')))
          ],
          onChanged: (v) => _updateFilter(() => onChanged(v)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _updateFilter(void Function() update) {
    setState(() => update());
  }

  Widget _buildActiveFilters() {
    List<Widget> chips = [];
    if (_selectedFilterType != null) {
      chips.add(
          _buildChip(_selectedFilterType!, () => _selectedFilterType = null));
    }
    if (_selectedCategory != null) {
      chips.add(_buildChip(
          categoryList.firstWhere(
              (c) => c['id'].toString() == _selectedCategory,
              orElse: () => {'category_name': 'Unknown'})['category_name'],
          () => _selectedCategory = null));
    }
    if (_selectedCuisine != null) {
      chips.add(_buildChip(
          cuisineList.firstWhere((c) => c['id'].toString() == _selectedCuisine,
              orElse: () => {'cuisine_name': 'Unknown'})['cuisine_name'],
          () => _selectedCuisine = null));
    }
    if (_selectedLevel != null) {
      chips.add(_buildChip(
          levelList.firstWhere((l) => l['id'].toString() == _selectedLevel,
              orElse: () => {'level_name': 'Unknown'})['level_name'],
          () => _selectedLevel = null));
    }
    if (selectedItemIds.isNotEmpty) {
      chips.add(_buildChip('${selectedItemIds.length} Ingredients',
          () => selectedItemIds.clear()));
    }
    return chips.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Wrap(spacing: 8, runSpacing: 4, children: chips));
  }

  Widget _buildChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(label),
      backgroundColor: primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: primaryColor),
      deleteIconColor: primaryColor,
      onDeleted: () {
        setState(() {
          onDelete();
          _filterRecipes();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Find Your Recipe",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Discover delicious recipes",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search recipes...",
              prefixIcon: Icon(Icons.search, color: primaryColor),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _filterRecipes();
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.filter_list_rounded, color: primaryColor),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
          ),

          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showIngredientSelectionDialog,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.red,
                image: DecorationImage(
                  image: AssetImage('assets/bgq.jpg'),
                  fit: BoxFit.cover,
                ),  
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background image (already set in decoration)
                  // Positioned text
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Generate recipes using the ingredients you have",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Active filters and reset button
          _buildActiveFilters(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${filteredRecipes.length} Recipes Found",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
              if (filteredRecipes.length != recipes.length)
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    "Reset All",
                    style: TextStyle(color: accentColor),
                  ),
                ),
            ],
          ),

          // Results
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : filteredRecipes.isEmpty
                  ? Center(
                      child: Text(
                        "No recipes found",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipePage(
                                recipeId: recipe['id'].toString(),
                                isEditable: false,
                              ),
                            ),
                          ),
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
                                  child: recipe['recipe_photo'] != null
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 14,
                                            color: accentColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            recipe['recipe_cookingtime'] ??
                                                'N/A',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
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

  @override
  void dispose() {
    _searchController.dispose();
    _ingredientSearchController.dispose();
    super.dispose();
  }
}
