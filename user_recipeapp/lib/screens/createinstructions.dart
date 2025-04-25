import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/recipepage.dart';

class Instructions extends StatefulWidget {
  final String recipieId;
  const Instructions({super.key, required this.recipieId});

  @override
  State<Instructions> createState() => _InstructionsState();
}

class _InstructionsState extends State<Instructions> {
  final TextEditingController _stepsController = TextEditingController();
  List<Map<String, dynamic>> instructions = [];

  @override
  void initState() {
    super.initState();
    fetchInstructions();
  }

  // Fetch instructions from database
  Future<void> fetchInstructions() async {
    try {
      final response = await supabase
          .from('tbl_instructions')
          .select()
          .eq('recipe_id', widget.recipieId);

      setState(() {
        instructions = response;
      });
    } catch (e) {
      print("ERROR FETCHING INSTRUCTIONS: $e");
    }
  }

  // Insert new instruction into database
  Future<void> insertInstruction() async {
    try {
      String stepText = _stepsController.text.trim();
      if (stepText.isNotEmpty) {
        await supabase.from('tbl_instructions').insert({
          'ingredient_instructions': stepText,
          'recipe_id': widget.recipieId,
        });

        _stepsController.clear();
        fetchInstructions(); // Refresh list after adding
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to add instruction. Try again!"),
          backgroundColor: Colors.red,
        ),
      );
      print("ERROR ADDING INSTRUCTION: $e");
    }
  }

  // Delete an instruction
  Future<void> deleteInstruction(int instructionId) async {
    try {
      await supabase
          .from('tbl_instructions')
          .delete()
          .match({'id': instructionId});
      fetchInstructions(); // Refresh list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete instruction. Try again!"),
          backgroundColor: Colors.red,
        ),
      );
      print("ERROR DELETING INSTRUCTION: $e");
    }
  }
  Future<void> saveRecipe () async {
    try {
      await supabase
          .from('tbl_recipe')
          .update({'recipe_status':1}).eq('id', widget.recipieId);
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RecipePage(recipeId: widget.recipieId,)),
    );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete instruction. Try again!"),
          backgroundColor: Colors.red,
        ),
      );
      print("ERROR DELETING INSTRUCTION: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Recieved ID: ${widget.recipieId}");
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
            // TextField for entering instructions
            TextField(
              controller: _stepsController,
              decoration: const InputDecoration(
                labelText: "Steps",
                border: OutlineInputBorder(),
              ),
              maxLength: 500,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: insertInstruction,
                icon: const Icon(Icons.add),
                label: const Text("Add Step"),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: instructions.length,
              itemBuilder: (context, index) {
                final instruction = instructions[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          instruction['ingredient_instructions'] ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => deleteInstruction(instruction['id']),
                        icon: const Icon(Icons.delete_forever_sharp, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 300),
            ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF1F7D53),
    foregroundColor: const Color.fromARGB(255, 245, 245, 245),
    minimumSize: const Size(200, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: () {
    saveRecipe();
  },
  child: const Text("SAVE"),
),

          ],
        ),
      ),
    );
  }
}
