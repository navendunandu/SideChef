import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/userprofile.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<Map<String, dynamic>> following = [];
  bool isLoading = true;
  
  // App theme colors
  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);
  final Color backgroundColor = const Color(0xFFF9F9F9);

  Future<void> _fetchFollowing() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await supabase
          .from('tbl_follow')
          .select('following_id, tbl_user!following_id(user_name, user_photo, user_id)')
          .eq('follower_id', supabase.auth.currentUser!.id);
      
      setState(() {
        following = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching following: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _unfollowUser(String followingId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.person_remove_rounded, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 12),
            const Text('Unfollow User'),
          ],
        ),
        content: const Text(
          'Are you sure you want to unfollow this user?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Unfollow', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase
            .from('tbl_follow')
            .delete()
            .eq('follower_id', supabase.auth.currentUser!.id)
            .eq('following_id', followingId);
        
        setState(() {
          following.removeWhere((f) => f['following_id'] == followingId);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Unfollowed successfully'),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        print('Error unfollowing user: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to unfollow user'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Following',
          style: TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchFollowing,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            )
          : following.isEmpty
              ? _buildEmptyState()
              : _buildFollowingList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Not following anyone yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find and follow chefs to see their recipes',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to search page - you'll need to implement this
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SearchUsersPage()));
            },
            icon: const Icon(Icons.search_rounded),
            label: const Text('Find Users'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: following.length,
      itemBuilder: (context, index) {
        final follow = following[index];
        final userData = follow['tbl_user'] ?? {};
        final userName = userData['user_name'] ?? 'Unknown User';
        final userPhoto = userData['user_photo'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    userId: userData['user_id'].toString(),
                  ),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Hero(
              tag: 'following_${follow['following_id']}',
              child: CircleAvatar(
                radius: 26,
                backgroundColor: accentColor.withOpacity(0.2),
                backgroundImage: userPhoto != null ? NetworkImage(userPhoto) : null,
                child: userPhoto == null
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),
            title: Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: secondaryColor,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Tap to view recipes',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.person_remove_rounded,
                color: Colors.red.shade400,
              ),
              onPressed: () => _unfollowUser(follow['following_id']),
              tooltip: 'Unfollow',
            ),
          ),
        );
      },
    );
  }
}

