import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;
  String filterType = 'All'; // Filter: All, App, Post

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    try {
      var query = supabase
          .from('tbl_complaint')
          .select()
          .order('created_at', ascending: false);

      final response = await query;
      print("Response $response");
      if (mounted) {
        setState(() {
          complaints = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching complaints: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching complaints: $e')),
        );
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _submitReply(int complaintId, String reply) async {
    try {
      // Use numeric value for complaint_status (1 for Completed)
      await supabase.from('tbl_complaint').update({
        'complaint_reply': reply,
        'complaint_status': 1, // Changed to numeric value for bigint column
      }).eq('id', complaintId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reply submitted successfully!'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _fetchComplaints(); // Refresh the list
      }
    } catch (e) {
      print('Error submitting reply: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting reply: $e')),
        );
      }
    }
  }

  void _showReplyDialog(int complaintId) {
    final TextEditingController replyController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: Text(
          'Reply to Complaint',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A3C34),
          ),
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: replyController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your reply here...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFA5D6A7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
            ),
            style: GoogleFonts.poppins(color: const Color(0xFF1A3C34)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Reply cannot be empty.';
              }
              if (value.trim().length < 3) {
                return 'Reply must be at least 3 characters.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _submitReply(complaintId, replyController.text);
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Submit',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredComplaints() {
    if (filterType == 'All') return complaints;
    return complaints.where((complaint) {
      if (filterType == 'App') return complaint['recipe_id'] == null;
      return complaint['recipe_id'] != null; // Post
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredComplaints = _filteredComplaints();

    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Complaints',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A3C34),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'View and manage your filed complaints',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['All', 'App', 'Post'].map((type) {
                    return ChoiceChip(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      label: Text(
                        type,
                        style: GoogleFonts.poppins(
                          color: filterType == type
                              ? Colors.white
                              : const Color(0xFF1A3C34),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: filterType == type,
                      selectedColor: const Color(0xFF2E7D32),
                      backgroundColor: const Color(0xFFA5D6A7).withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onSelected: (selected) {
                        if (selected) setState(() => filterType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: filteredComplaints.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.report_problem_outlined,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 20),
                              Text(
                                'No complaints filed yet',
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
                          itemCount: filteredComplaints.length,
                          itemBuilder: (context, index) {
                            final complaint = filteredComplaints[index];
                            // Check for numeric status (1 for Completed, 0 for Pending)
                            final bool isCompleted = complaint['complaint_status'] == 1;
                            final bool isAppComplaint = complaint['recipe_id'] == null;

                            return GestureDetector(
                              // Only allow tap for app-based, non-completed complaints
                              onTap: isAppComplaint && !isCompleted
                                  ? () => _showReplyDialog(complaint['id'])
                                  : null, // Disable tap for post complaints or completed
                              child: Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              complaint['complaint_title'] ?? 'No Title',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: const Color(0xFF1A3C34),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isCompleted
                                                  ? const Color(0xFFA5D6A7).withOpacity(0.3)
                                                  : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isCompleted ? 'Completed' : 'Pending',
                                              style: GoogleFonts.poppins(
                                                color: isCompleted
                                                    ? const Color(0xFF2E7D32)
                                                    : Colors.grey[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        complaint['complaint_content'] ?? 'No Content',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            isAppComplaint
                                                ? Icons.bug_report_outlined
                                                : Icons.restaurant_menu,
                                            size: 14,
                                            color: const Color(0xFF2E7D32),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isAppComplaint
                                                ? 'App Complaint'
                                                : 'Post Complaint',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFF1A3C34),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(Icons.calendar_today,
                                              size: 14, color: const Color(0xFF2E7D32)),
                                          const SizedBox(width: 4),
                                          Text(
                                            complaint['created_at']
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
                                      if (isCompleted && complaint['complaint_reply'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Your Reply:',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1A3C34),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                complaint['complaint_reply'] ?? 'No Reply',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: const Color(0xFF1A3C34),
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
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