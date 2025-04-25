import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Userlist extends StatefulWidget {
  const Userlist({super.key});

  @override
  State<Userlist> createState() => _UserlistState();
}

class _UserlistState extends State<Userlist> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      var query = supabase
          .from('tbl_user')
          .select()
          .order('created_at', ascending: false);

      final response = await query;
      print("Users response: $response"); // Debug: Check the data
      if (mounted) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: $e')),
        );
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // Green header
        title: Text(
          'User List',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFA5D6A7).withOpacity(0.2), // Light green background
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User List',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A3C34),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View all registered users',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: users.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 80, color: Colors.grey[400]),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No users found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // User Photo
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: user['user_photo'] != null
                                              ? NetworkImage(user['user_photo'])
                                              : const AssetImage(
                                                  'assets/placeholder.png') as ImageProvider,
                                          backgroundColor: Colors.grey[200],
                                          onBackgroundImageError: (_, __) =>
                                              const AssetImage('assets/placeholder.png'),
                                        ),
                                        const SizedBox(width: 16),
                                        // User Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user['user_name'] ?? 'No User Name',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: const Color(0xFF1A3C34),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                user['user_email'] ?? 'No Email',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              if (user['user_contact'] != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    user['user_contact'] ?? 'No Contact',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today,
                                                      size: 14,
                                                      color: const Color(0xFF2E7D32)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    user['created_at']
                                                            ?.toString()
                                                            .substring(0, 10) ??
                                                        'N/A',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFA5D6A7)
                                                .withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Active',
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF2E7D32),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
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
              ),
      ),
    );
  }
}