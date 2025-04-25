import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/complaints.dart';

class AddComment extends StatefulWidget {
  final int recipeId;
  const AddComment({super.key, required this.recipeId});

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0; // Rating value
  bool isPosting = false;
  File? _selectedImage;

  // Function to pick an image
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to add a comment and rating
  Future<void> addComment() async {
    if ((_commentController.text.trim().isEmpty && _selectedImage == null) || _rating == 0 || isPosting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating and comment.")),
      );
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    setState(() {
      isPosting = true;
    });

    String? imageUrl;
    if (_selectedImage != null) {
      final String fileName = "comment_images/${DateTime.now().millisecondsSinceEpoch}.jpg";
      final imageBytes = await _selectedImage!.readAsBytes();
      await supabase.storage.from('reciepes').uploadBinary(fileName, imageBytes);
      imageUrl = supabase.storage.from('reciepes').getPublicUrl(fileName);
    }

    try {
      // Insert both comment and rating in one row
      await supabase.from('tbl_comment').insert({
        'recipe_id': widget.recipeId,
        'user_id': user.id,
        'comment_content': _commentController.text.trim(),
        'comment_photo': imageUrl,
        'comment_date': DateTime.now().toIso8601String(),
        'comment_ratingvalue': _rating, // <-- Add rating here
      });

      _commentController.clear();
      _selectedImage = null;
      _rating = 0;
      Navigator.pop(context); // Close the page after posting
    } catch (e) {
      print("Error adding comment: $e");
    } finally {
      setState(() {
        isPosting = false;
      });
    }
  }

  // Widget to build star rating UI
  Widget buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: index < _rating ? Colors.amber : Colors.grey,
      ),
      onPressed: () => setState(() => _rating = index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Rate & Comment", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
       
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Rating Section
            const Text("Rate this Recipe:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => buildStar(index)),
            ),
            const SizedBox(height: 70),

            // Comment Input
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write your comment...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),

            // Image Preview
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
            const SizedBox(height: 10),

            // Image Picker and Submit Button
            Row(
              children: [
                IconButton(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image, color: Color(0xFF1F7D53), size: 30),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: isPosting ? null : addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F7D53),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Post",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
                   const SizedBox(height: 50),  
                   Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text("Have any Complaints? "),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Complaints(
              recipeId: widget.recipeId,
            ),
          ),
        );
      },
      child: const Text(
        "Report Here",
        style: TextStyle(
          color:  Color(0xFF1F7D53),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
)
          ],
        ),
      ),
    );
  }
}
