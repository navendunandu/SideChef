import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_recipeapp/main.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
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
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

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

  void _showReportBugDialog() {
    final _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: Text(
          'Report a Bug',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A3C34),
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Briefly describe the issue...',
                  labelStyle: GoogleFonts.poppins(color: const Color(0xFF1A3C34).withOpacity(0.7)),
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFA5D6A7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.poppins(color: const Color(0xFF1A3C34)),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the issue in detail...',
                  labelStyle: GoogleFonts.poppins(color: const Color(0xFF1A3C34).withOpacity(0.7)),
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFA5D6A7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.poppins(color: const Color(0xFF1A3C34)),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
            ],
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
                  try {
                    await supabase.from('tbl_complaint').insert({
                      'user_id': supabase.auth.currentUser!.id,
                      'complaint_title': titleController.text,
                      'complaint_content': contentController.text,
                      'created_at': DateTime.now().toIso8601String(),
                      'complaint_status': '0',
                      // recipe_id is null for app complaints
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Complaint submitted successfully!'),
                          backgroundColor: const Color(0xFF2E7D32),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                      _fetchComplaints();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
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

    void _showReplyDialog(int complaintId) {
      final _formKey = GlobalKey<FormState>();
      final replyController = TextEditingController();

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
                labelText: 'Your Reply',
                hintText: 'Enter your response...',
                labelStyle: GoogleFonts.poppins(color: const Color(0xFF1A3C34).withOpacity(0.7)),
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFA5D6A7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.poppins(color: const Color(0xFF1A3C34)),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a reply' : null,
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
                  try {
                    await supabase
                        .from('tbl_complaint')
                        .update({
                          'complaint_reply': replyController.text,
                          'complaint_status': '1', // Mark as replied
                        })
                        .eq('id', complaintId);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Reply submitted successfully!'),
                          backgroundColor: const Color(0xFF2E7D32),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                      _fetchComplaints();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
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

      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F5), // Light green-gray
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32), // Deep green
          elevation: 0,
          title: Text(
            'My Complaints',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _showReportBugDialog,
              child: Text(
                'Report Bug',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: isLoading
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
                      'View your filed complaints and admin responses',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['All', 'App', 'Post'].map((type) {
                        return ChoiceChip(
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
                                final bool isReplied = complaint['complaint_status'] == 1;
                                final bool isAppComplaint = complaint['recipe_id'] == null;

                                return Card(
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
                                                color: isReplied
                                                    ? const Color(0xFFA5D6A7).withOpacity(0.3)
                                                    : Colors.grey[200],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isReplied ? 'Replied' : 'Pending',
                                                style: GoogleFonts.poppins(
                                                  color: isReplied
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
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
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
                                            if (!isAppComplaint && !isReplied)
                                              ElevatedButton(
                                                onPressed: () => _showReplyDialog(complaint['id']),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF2E7D32),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 8),
                                                ),
                                                child: Text(
                                                  'Reply',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (isReplied && complaint['complaint_reply'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Reply:',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF1A3C34),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  complaint['complaint_reply'],
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
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      );
    }
  }