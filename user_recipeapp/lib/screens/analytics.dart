import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_recipeapp/main.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int totalViews = 0;
  int followerViews = 0;
  int nonFollowerViews = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      // Fetch user's recipes
      final recipesResponse = await supabase
          .from('tbl_recipe')
          .select('id')
          .eq('user_id', userId);

      List<Map<String, dynamic>> recipes = List<Map<String, dynamic>>.from(recipesResponse);
      List<String> recipeIds = recipes.map((r) => r['id'].toString()).toList();

      // Fetch views for these recipes
      final viewsResponse = await supabase
          .from('tbl_recent')
          .select('user_id')
          .inFilter('recipe_id', recipeIds);

      List<Map<String, dynamic>> views = List<Map<String, dynamic>>.from(viewsResponse);
      totalViews = views.length;

      // Fetch followers
      final followersResponse = await supabase
          .from('tbl_follow')
          .select('follower_id')
          .eq('following_id', userId);

      List<String> followerIds = List<Map<String, dynamic>>.from(followersResponse)
          .map((f) => f['follower_id'].toString())
          .toList();

      // Calculate follower vs non-follower views
      followerViews = views.where((view) => followerIds.contains(view['user_id'].toString())).length;
      nonFollowerViews = totalViews - followerViews;
    } catch (e) {
      print('Error fetching analytics: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load analytics: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5), // Light green-gray
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // Deep green
        elevation: 0,
        title: Text(
          'My Analytics',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Recipe Analytics',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A3C34), // Dark green
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Insights for ${supabase.auth.currentUser?.email ?? "You"}',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    _buildStatCard('Total Views', totalViews.toString(), Icons.visibility),
                    const SizedBox(height: 24),
                    _buildViewSourceChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFA5D6A7).withOpacity(0.3), // Light green
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 28), // Deep green
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF1A3C34), // Dark green
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32), // Deep green
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewSourceChart() {
    final followerPercentage = totalViews > 0 ? (followerViews / totalViews) * 100 : 0.0;
    final nonFollowerPercentage = totalViews > 0 ? (nonFollowerViews / totalViews) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'View Sources',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A3C34), // Dark green
            ),
          ),
          const SizedBox(height: 16),
          totalViews == 0
              ? _buildEmptyState('No views yet')
              : Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: const Color(0xFF2E7D32), // Deep green
                              value: followerViews.toDouble(),
                              title: '${followerPercentage.toStringAsFixed(1)}%',
                              radius: 50,
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: const Color(0xFFA5D6A7), // Light green
                              value: nonFollowerViews.toDouble(),
                              title: '${nonFollowerPercentage.toStringAsFixed(1)}%',
                              radius: 50,
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A3C34),
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('Followers', const Color(0xFF2E7D32), followerViews),
                        const SizedBox(height: 8),
                        _buildLegendItem('Non-Followers', const Color(0xFFA5D6A7), nonFollowerViews),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A3C34)),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}