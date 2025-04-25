import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_recipeapp/components/form_validation.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/login.dart';
import 'package:path/path.dart' as path; 

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  List<Map<String, dynamic>> registrationList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String uid) async {
    try {
      String fileExtension = path.extension(_image!.path);
      String fileName = 'User-$uid$fileExtension';
      await supabase.storage.from('reciepes').upload(fileName, _image!);
      final imageUrl = supabase.storage.from('reciepes').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> register() async {
    if (!formkey.currentState!.validate()) return;

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a profile picture."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authentication = await supabase.auth.signUp(
        password: _passwordController.text,
        email: _emailController.text,
      );
      String uid = authentication.user!.id;
      insertUser(uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> insertUser(String uid) async {
    try {
      String name = _nameController.text;
      String email = _emailController.text;
      String contact = _contactController.text;
      String password = _passwordController.text;
      String? url = await _uploadImage(uid); 
      await supabase.from('tbl_user').insert({
        'user_id': uid,
        'user_name': name,
        'user_email': email,
        'user_contact': contact,
        'user_password': password,
        'user_photo': url,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "REGISTRATED SUCCESSFULLY",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
      _passwordController.clear();
      _confirmpasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR REGISTERING: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 251, 251),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 251, 251, 251),
        title: Center(child: Text(" REGISTRATION")),
      ),
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.grey[200],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 58, 58, 58),
                        size: 50,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Name",
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                // Only allow Gmail addresses
                if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(value.trim())) {
                  return 'Please enter a valid Gmail address';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _contactController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Contact number is required';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                  return 'Contact must be 10 digits';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Contact",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              obscureText: !_passwordVisible,
              controller: _passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain at least one uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must contain at least one lowercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must contain at least one number';
                }
                if (!RegExp(r'[!@#\$&*~_.,;:^%]').hasMatch(value)) {
                  return 'Password must contain at least one special character';
                }
                return null;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: const Color.fromARGB(255, 236, 236, 236),
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              obscureText: !_confirmPasswordVisible,
              controller: _confirmpasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: const Color.fromARGB(255, 236, 236, 236),
                labelText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                register();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Changed to green
                foregroundColor: Colors.white, // Changed text color to white for better contrast
              ),
              child: const Text("REGISTER"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: const Text("Sign In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}