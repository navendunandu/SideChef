import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/createinstructions.dart';

class Ingredients extends StatefulWidget {
  final String recipieId;
  const Ingredients({super.key, required this.recipieId});

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedIngredient;
  String? _selectedUnit;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];

  final List<String> _measurementUnits = [
    'tsp', 'tbsp', 'cup', 'g', 'kg', 'ml', 'l', 'nos', 'bag', 'pinch',
    'dash', 'drop', 'clove', 'pod', 'stick', 'handful', 'slice', 'piece',
    'bunch', 'sprig', 'block', 'liter', 'gram', 'small bowl', 'big bowl',
    'heap', 'sheet', 'can', 'bottle', 'packet', 'scoop'
  ];

  @override
  void initState() {
    super.initState();
    fetchItems();
    fetchIngredients();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = items.where((item) {
        final itemName = item['item_name']?.toString().toLowerCase() ?? '';
        return itemName.contains(query);
      }).toList();
    });
  }

  void _showIngredientsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Ingredients',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setModalState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.isEmpty ? items.length : filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems.isEmpty
                            ? items[index]
                            : filteredItems[index];
                        return ListTile(
                          title: Text(item['item_name']?.toString() ?? ''),
                          onTap: () {
                            setState(() {
                              _selectedIngredient = item['id']?.toString();
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> insertIngredients() async {
    try {
      if (_selectedIngredient != null && _selectedUnit != null) {
        String quantity = _quantityController.text;

        await supabase.from('tbl_ingredient').insert({
          'item_id': _selectedIngredient,
          'ingredient_quantity': quantity,
          'reciepe_id': widget.recipieId,
          'ingredient_unit': _selectedUnit,
        });
        _quantityController.clear();

        fetchIngredients();
        setState(() {
          _selectedIngredient = null;
          _selectedUnit = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR ADDING RECIPE: $e");
    }
  }

  Future<void> fetchItems() async {
    try {
      final response = await supabase.from('tbl_item').select();
      setState(() {
        items = response;
        filteredItems = response;
      });
    } catch (e) {
      print("ERROR FETCHING INGREDIENTS: $e");
    }
  }

  Future<void> deleteIngredient(int ingredientId) async {
    try {
      await supabase.from('tbl_ingredient').delete().match({'id': ingredientId});
      fetchIngredients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete. Try again!"),
          backgroundColor: Colors.red,
        ),
      );
      print("ERROR DELETING INGREDIENT: $e");
    }
  }

  List<Map<String, dynamic>> ingredients = [];

  Future<void> fetchIngredients() async {
    try {
      final response = await supabase
          .from('tbl_ingredient')
          .select("*, tbl_item(*)")
          .eq('reciepe_id', widget.recipieId);
      setState(() {
        ingredients = response;
      });
    } catch (e) {
      print("ERROR FETCHING INGREDIENTS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find Best Recipes for Cooking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Ingredient",
                border: const OutlineInputBorder(),
                hintText: _selectedIngredient != null
                    ? items
                        .firstWhere((item) => item['id'].toString() == _selectedIngredient)['item_name']
                    : 'Select an ingredient',
              ),
              onTap: _showIngredientsModal,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: "Quantity",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: "Unit",
                      border: OutlineInputBorder(),
                    ),
                    items: _measurementUnits.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value;
                      });
                    },
                    validator: (value) => value == null ? 'Select unit' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  insertIngredients();
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Ingredient"),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              itemCount: ingredients.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 244, 209),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ingredient['tbl_item']['item_name']?.toString() ?? ''),
                      Text(
                          "${ingredient['ingredient_quantity']?.toString()} ${ingredient['ingredient_unit']?.toString()}"),
                      IconButton(
                        onPressed: () {
                          deleteIngredient(ingredient['id']);
                        },
                        icon: const Icon(Icons.delete_forever_sharp, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F7D53),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Instructions(recipieId: widget.recipieId),
                  ),
                );
              },
              child: const Text("NEXT"),
            ),
          ],
        ),
      ),
    );
  }
}