import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/complaints.dart';

class Comments extends StatefulWidget {
  final int recipeId;
  const Comments({super.key, required this.recipeId});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  bool isPosting = false;
  File? _selectedImage;

  Future<void> fetchComments() async {
    try {
      final response = await supabase
          .from('tbl_comment')
          .select(
              'id, comment_content, comment_date, comment_photo, user_id, tbl_user(user_name, user_photo)')
          .eq('recipe_id', widget.recipeId)
          .order('comment_date', ascending: false);

      setState(() {
        comments = response;
      });
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> addComment() async {
    if (_commentController.text.trim().isEmpty && _selectedImage == null ||
        isPosting) return;

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
      final String fileName =
          "comment_images/${DateTime.now().millisecondsSinceEpoch}.jpg";
      await supabase.storage.from('reciepes').upload(fileName, _selectedImage!);
      imageUrl = supabase.storage.from('reciepes').getPublicUrl(fileName);
    }

    try {
      await supabase.from('tbl_comment').insert({
        'recipe_id': widget.recipeId,
        'user_id': user.id,
        'comment_content': _commentController.text.trim(),
        'comment_photo': imageUrl,
        'comment_date': DateTime.now().toIso8601String(),
      });

      _commentController.clear();
      _selectedImage = null;
      await fetchComments();
    } catch (e) {
      print("Error adding comment: $e");
    } finally {
      setState(() {
        isPosting = false;
      });
    }
  }

  void _editComment(Map<String, dynamic> comment) {
    TextEditingController editController =
        TextEditingController(text: comment['comment_content']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Comment"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Update your comment"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await supabase
                      .from('tbl_comment')
                      .update({'comment_content': editController.text}).eq(
                          'id', comment['id']);

                  Navigator.pop(context);
                  fetchComments(); // Refresh comments
                } catch (e) {
                  print("Error updating comment: $e");
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(int commentId) async {
    try {
      await supabase.from('tbl_comment').delete().eq('id', commentId);
      fetchComments(); // Refresh comments
    } catch (e) {
      print("Error deleting comment: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Comments", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.report_gmailerrorred_outlined,
              color: Colors.red,
              size: 30,
            ), // Complaint Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Complaints(recipeId: widget.recipeId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text("No comments yet."))
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final commentId = comment['id'];
                      final userName =
                          comment['tbl_user']['user_name'] ?? 'Unknown';
                      final userPhoto = comment['tbl_user']['user_photo'] ?? '';
                      final commentImage = comment['comment_photo'] ?? '';
                      final currentUserId = supabase.auth.currentUser?.id;
                      final isUserComment = comment['user_id'] == currentUserId;
                      return Card(
                        color: Colors.white, // Set card background to white
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        elevation: 2, // Add slight shadow for a clean look
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Rounded corners for a modern feel
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: userPhoto.isNotEmpty
                                        ? NetworkImage(userPhoto)
                                        : null,
                                    child: userPhoto.isEmpty
                                        ? const Icon(Icons.person,
                                            color: Colors.black)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['comment_content'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "$userName - ${formatDate(comment['comment_date'])}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == "edit") {
                                        _editComment(comment);
                                      } else if (value == "delete") {
                                        _deleteComment(comment['id']);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: "edit",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: const Color(0xFF1F7D53),
                                            ),
                                            SizedBox(width: 8),
                                            Text("Edit"),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: "delete",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: const Color(0xFF1F7D53),
                                            ),
                                            SizedBox(width: 8),
                                            Text("Delete"),
                                          ],
                                        ),
                                      ),
                                    ],
                                    icon: const Icon(Icons.more_horiz,
                                        color: Colors.black54),
                                  ),
                                ],
                              ),
                              if (commentImage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded image corners
                                    child: Image.network(commentImage,
                                        height: 150, fit: BoxFit.cover),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Comment Input Field & Image Upload
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image,
                      color: Color(0xFF1F7D53), size: 30),
                ),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isPosting ? null : addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1F7D53), // Dark green color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12), // Nice padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    elevation: 5, // Shadow effect
                    shadowColor: const Color.fromARGB(255, 239, 239, 239)
                        .withOpacity(0.5), // Soft shadow
                  ),
                  child: isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Post",
                          style: TextStyle(
                            color: Colors.white, // White text color
                            fontSize: 16, // Slightly larger text
                            fontWeight: FontWeight.w600, // Semi-bold
                            letterSpacing: 1.0, // Spaced-out text
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
