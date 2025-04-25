import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  List<Map<String, dynamic>> levelList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertLevel() async {
    try {
      String name = _nameController.text.trim();
      await supabase.from('tbl_level').insert({'level_name': name});
      showSnackbar("Level Added Successfully!", const Color(0xFF2E7D32));
      _nameController.clear();
      fetchLevels();
    } catch (e) {
      showSnackbar("Failed to add level. Try again!", Colors.red);
      print("ERROR ADDING LEVEL: $e");
    }
  }

  Future<void> fetchLevels() async {
    try {
      final response = await supabase.from('tbl_level').select();
      setState(() {
        levelList = response;
      });
    } catch (e) {
      print("ERROR FETCHING LEVELS: $e");
    }
  }

  Future<void> deleteLevel(String id) async {
    try {
      await supabase.from("tbl_level").delete().eq("id", id);
      showSnackbar("Level Deleted", Colors.redAccent);
      fetchLevels();
    } catch (e) {
      print("ERROR DELETING LEVEL: $e");
    }
  }

  Future<void> editLevel() async {
    try {
      await supabase.from('tbl_level').update(
        {'level_name': _nameController.text.trim()},
      ).eq("id", editID);
      showSnackbar("Level Updated Successfully!", const Color(0xFF2E7D32));
      setState(() {
        editID = 0;
      });
      _nameController.clear();
      fetchLevels();
    } catch (e) {
      print("ERROR EDITING LEVEL: $e");
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
    fetchLevels();
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
            'Manage Levels',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C34), // Dark green for title
            ),
          ),
          const SizedBox(height: 16),

          // Level Input Form
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
                          return "Please enter a level name.";
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
                        bool isDuplicate = levelList.any((level) =>
                            level['level_name'].toString().toLowerCase() ==
                                trimmed.toLowerCase() &&
                            (editID == 0 || level['id'] != editID));
                        if (isDuplicate) {
                          return 'This level already exists.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Level Name",
                        labelStyle: const TextStyle(color: Color(0xFF1A3C34)),
                        hintText: "Enter level",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.stairs,
                          color: Color(0xFF2E7D32), // Deep green icon
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (editID == 0) {
                            insertLevel();
                          } else {
                            editLevel();
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
                        editID == 0 ? "Add Level" : "Update Level",
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

          // Level List
          Expanded(
            child: levelList.isEmpty
                ? const Center(
                    child: Text(
                      'No levels available.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A3C34),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: levelList.length,
                    itemBuilder: (context, index) {
                      final data = levelList[index];
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
                              Icons.stairs,
                              color: Color(0xFF1A3C34), // Dark green icon
                            ),
                          ),
                          title: Text(
                            data['level_name'],
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
                                    _nameController.text = data['level_name'];
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
                                  deleteLevel(data['id'].toString());
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