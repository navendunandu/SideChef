import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/recipepage.dart';
import 'package:user_recipeapp/screens/userprofile.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({super.key});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<Map<String, dynamic>> followers = [];
  bool isLoading = true;

  // App theme colors
  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);
  final Color backgroundColor = const Color(0xFFF9F9F9);

  Future<void> _fetchFollowers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('tbl_follow')
          .select('follower_id, tbl_user!follower_id(user_name, user_photo,user_id)')
          .eq('following_id', supabase.auth.currentUser!.id);

      setState(() {
        followers = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching followers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFollower(String followerId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.person_remove, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 12),
            const Text('Remove Follower'),
          ],
        ),
        content: const Text(
          'Are you sure you want to remove this follower?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Colors.grey.shade600, fontWeight: FontWeight.w500),
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
            child: const Text('Remove',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase
            .from('tbl_follow')
            .delete()
            .eq('following_id', supabase.auth.currentUser!.id)
            .eq('follower_id', followerId);

        setState(() {
          followers.removeWhere((f) => f['follower_id'] == followerId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Follower removed successfully'),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        print('Error removing follower: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to remove follower'),
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
    _fetchFollowers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Followers',
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
            onPressed: _fetchFollowers,
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
          : followers.isEmpty
              ? _buildEmptyState()
              : _buildFollowersList(),
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
            'No followers yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your recipes to attract followers',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final follower = followers[index];
        final userData = follower['tbl_user'] ?? {};
        final userName = userData['user_name'] ?? 'Unknown User';
        final userPhoto = userData['user_photo'];
        print(userData);
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Hero(
              tag: 'follower_${follower['follower_id']}',
              child: CircleAvatar(
                radius: 26,
                backgroundColor: accentColor.withOpacity(0.2),
                backgroundImage:
                    userPhoto != null ? NetworkImage(userPhoto) : null,
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
            trailing: IconButton(
              icon: Icon(
                Icons.person_remove_rounded,
                color: Colors.red.shade400,
              ),
              onPressed: () => _removeFollower(follower['follower_id']),
              tooltip: 'Remove follower',
            ),
          ),
        );
      },
    );
  }
}
