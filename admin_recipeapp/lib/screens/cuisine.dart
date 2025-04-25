import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';

class Cuisine extends StatefulWidget {
  const Cuisine({super.key});

  @override
  State<Cuisine> createState() => _CuisineState();
}

class _CuisineState extends State<Cuisine> {
  List<Map<String, dynamic>> cuisineList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertCuisine() async {
    try {
      String name = _nameController.text.trim();
      await supabase.from('tbl_cuisine').insert({'cuisine_name': name});
      showSnackbar("Cuisine Added Successfully!", const Color(0xFF2E7D32));
      _nameController.clear();
      fetchCuisine();
    } catch (e) {
      showSnackbar("Failed to add cuisine. Try again!", Colors.red);
      print("ERROR ADDING CUISINE: $e");
    }
  }

  Future<void> fetchCuisine() async {
    try {
      final response = await supabase.from('tbl_cuisine').select();
      setState(() {
        cuisineList = response;
      });
    } catch (e) {
      print("ERROR FETCHING CUISINES: $e");
    }
  }

  Future<void> deleteCuisine(String id) async {
    try {
      await supabase.from("tbl_cuisine").delete().eq("id", id);
      showSnackbar("Cuisine Deleted", Colors.redAccent);
      fetchCuisine();
    } catch (e) {
      print("ERROR DELETING CUISINE: $e");
    }
  }

  Future<void> editCuisine() async {
    try {
      await supabase.from('tbl_cuisine').update(
        {'cuisine_name': _nameController.text.trim()},
      ).eq("id", editID);
      showSnackbar("Cuisine Updated Successfully!", const Color(0xFF2E7D32));
      setState(() {
        editID = 0;
      });
      _nameController.clear();
      fetchCuisine();
    } catch (e) {
      print("ERROR EDITING CUISINE: $e");
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCuisine();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F8E9), // Very light green background
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Manage Cuisines',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C34), // Dark green for title
            ),
          ),
          const SizedBox(height: 16),

          // Cuisine Input Form
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9), // Glassmorphism effect
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(color: Color(0xFF1A3C34)),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a cuisine name.";
                        }
                        String trimmed = value.trim();
                        // Only letters and spaces
                        if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(trimmed)) {
                          return 'Name must contain only letters and spaces.';
                        }
                        // Must start with a capital letter
                        if (!RegExp(r'^[A-Z]').hasMatch(trimmed)) {
                          return 'Name must start with a capital letter.';
                        }
                        // No duplicate (case-insensitive)
                        bool isDuplicate = cuisineList.any((cuisine) =>
                            cuisine['cuisine_name'].toString().toLowerCase() == trimmed.toLowerCase() &&
                            (editID == 0 || cuisine['id'] != editID));
                        if (isDuplicate) {
                          return 'This cuisine already exists.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Cuisine Name",
                        labelStyle: const TextStyle(color: Color(0xFF1A3C34)),
                        hintText: "Enter cuisine",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.restaurant,
                          color: Color(0xFF2E7D32), // Deep green icon
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (editID == 0) {
                            insertCuisine();
                          } else {
                            editCuisine();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32), // Deep green button
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                      ),
                      child: Text(
                        editID == 0 ? "Add Cuisine" : "Update Cuisine",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Cuisine List
          Expanded(
            child: cuisineList.isEmpty
                ? const Center(
                    child: Text(
                      'No cuisines available.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A3C34),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: cuisineList.length,
                    itemBuilder: (context, index) {
                      final data = cuisineList[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9), // Glassmorphism effect
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFA5D6A7), // Light green
                            child: const Icon(
                              Icons.restaurant,
                              color: Color(0xFF1A3C34), // Dark green icon
                            ),
                          ),
                          title: Text(
                            data['cuisine_name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A3C34),
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              // Edit Button
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF2E7D32), // Deep green
                                ),
                                onPressed: () {
                                  setState(() {
                                    editID = data['id'];
                                    _nameController.text = data['cuisine_name'];
                                  });
                                },
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  deleteCuisine(data['id'].toString());
                                },
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
    );
  }
}