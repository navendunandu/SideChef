import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';

class Diet extends StatefulWidget {
  const Diet({super.key});

  @override
  State<Diet> createState() => _DietState();
}

class _DietState extends State<Diet> {
  List<Map<String, dynamic>> dietList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertDiet() async {
    try {
      String name = _nameController.text.trim();
      await supabase.from('tbl_diet').insert({'diet_name': name});
      showSnackbar("Diet Added Successfully!", const Color(0xFF2E7D32));
      _nameController.clear();
      fetchCuisine();
    } catch (e) {
      showSnackbar("Failed to add Diet. Try again!", Colors.red);
      print("ERROR ADDING DIET: $e");
    }
  }

  Future<void> fetchCuisine() async {
    try {
      final response = await supabase.from('tbl_diet').select();
      setState(() {
        dietList = response;
      });
    } catch (e) {
      print("ERROR FETCHING Diet: $e");
    }
  }

  Future<void> deleteDiet(String id) async {
    try {
      await supabase.from("tbl_diet").delete().eq("id", id);
      showSnackbar("Diet Deleted", Colors.redAccent);
      fetchCuisine();
    } catch (e) {
      print("ERROR DELETING Diet $e");
    }
  }

  Future<void> editDiet() async {
    try {
      await supabase.from('tbl_diet').update(
        {'diet_name': _nameController.text.trim()},
      ).eq("id", editID);
      showSnackbar("Diet Updated Successfully!", const Color(0xFF2E7D32));
      setState(() {
        editID = 0;
      });
      _nameController.clear();
      fetchCuisine();
    } catch (e) {
      print("ERROR EDITING Diet: $e");
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
            'Manage Diets',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C34), // Dark green for title
            ),
          ),
          const SizedBox(height: 16),

          // Diet Input Form
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
                          return "Please enter a Diet name.";
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name must contain only letters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Diet Name",
                        labelStyle: const TextStyle(color: Color(0xFF1A3C34)),
                        hintText: "Enter Diet",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.restaurant_menu,
                          color: Color(0xFF2E7D32), // Deep green icon
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (editID == 0) {
                            insertDiet();
                          } else {
                            editDiet();
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
                        editID == 0 ? "Add Diet" : "Update Diet",
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

          // Diet List
          Expanded(
            child: dietList.isEmpty
                ? const Center(
                    child: Text(
                      'No diets available.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A3C34),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: dietList.length,
                    itemBuilder: (context, index) {
                      final data = dietList[index];
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
                              Icons.restaurant_menu,
                              color: Color(0xFF1A3C34), // Dark green icon
                            ),
                          ),
                          title: Text(
                            data['diet_name'],
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
                                    _nameController.text = data['diet_name'];
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
                                  deleteDiet(data['id'].toString());
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