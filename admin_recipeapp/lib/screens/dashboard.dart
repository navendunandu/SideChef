import 'package:flutter/material.dart';
import 'package:admin_recipeapp/main.dart'; // Assuming supabase is here
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For charts

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  int totalUsers = 0;
  int totalRecipes = 0;
  int newComplaints = 0;
  List<Map<String, dynamic>> recipePostingData = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch total users
      final usersResponse = await supabase
          .from('tbl_user')
          .select('user_id')
          .count(CountOption.exact);

      // Fetch total recipes
      final recipesResponse = await supabase
          .from('tbl_recipe')
          .select('id')
          .count(CountOption.exact);

      // Fetch new complaints (complaint_status = 0)
      final complaintsResponse = await supabase
          .from('tbl_complaint')
          .select('id')
          .eq('complaint_status', '0')
          .count(CountOption.exact);

      // Fetch recipe posting data for the last 6 months (Oct 2024 - Mar 2025)
      final recipesWithDates = await supabase
          .from('tbl_recipe')
          .select('created_at')
          .gte('created_at', '2024-10-01T00:00:00+00')
          .lte('created_at', '2025-03-31T23:59:59+00');

      final monthlyRecipes = List<int>.filled(6, 0); // Oct 2024 to Mar 2025
      for (var recipe in recipesWithDates) {
        final createdAt = DateTime.parse(recipe['created_at']);
        final year = createdAt.year;
        final month = createdAt.month;
        int monthIndex;

        if (year == 2024) {
          monthIndex = month - 10; // Oct 2024 = 0, Nov 2024 = 1, Dec 2024 = 2
        } else if (year == 2025) {
          monthIndex = month + 2; // Jan 2025 = 3, Feb 2025 = 4, Mar 2025 = 5
        } else {
          continue;
        }

        if (monthIndex >= 0 && monthIndex < 6) {
          monthlyRecipes[monthIndex]++;
        }
      }

      setState(() {
        totalUsers = usersResponse.count ?? 0;
        totalRecipes = recipesResponse.count ?? 0;
        newComplaints = complaintsResponse.count ?? 0;
        recipePostingData = List.generate(
            6, (index) => {'monthIndex': index, 'count': monthlyRecipes[index]});
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D32), // Deep green for loading indicator
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          const Text(
            'Welcome to Recipe Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C34), // Dark green for title
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of your recipe application',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          GridView.count(
            childAspectRatio: 2.0,
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                'Total Users',
                totalUsers.toString(),
                Icons.people,
                const Color(0xFF2E7D32), // Deep green for users
              ),
              _buildStatCard(
                'Total Recipes',
                totalRecipes.toString(),
                Icons.restaurant_menu,
                const Color(0xFFA5D6A7), // Light green for recipes
              ),
              _buildStatCard(
                'New Complaints',
                newComplaints.toString(),
                Icons.warning,
                const Color(0xFFFFCA28), // Amber for complaints
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recipe Posting Overview Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recipe Posting Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3C34),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: recipePostingData.isEmpty
                      ? _buildEmptyState('No recipe posting data')
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF1A3C34),
                                      ),
                                    );
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    const monthNames = [
                                      'Oct',
                                      'Nov',
                                      'Dec',
                                      'Jan',
                                      'Feb',
                                      'Mar'
                                    ];
                                    final index = value.toInt();
                                    if (index >= 0 && index < monthNames.length) {
                                      return Text(
                                        monthNames[index],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF1A3C34),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _createRecipePostingSpots(),
                                isCurved: true,
                                color: const Color(0xFF2E7D32), // Deep green for line chart
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF2E7D32).withOpacity(0.2),
                                ),
                              ),
                            ],
                            minX: 0,
                            maxX: 5,
                            minY: 0,
                            maxY: _calculateMaxY(),
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

  // Helper method to build stat cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _StatCardContent(
            title: title,
            value: value,
            icon: icon,
            color: color,
          ),
        );
      },
    );
  }

  // Helper method for empty state
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create line chart spots for recipe posting
  List<FlSpot> _createRecipePostingSpots() {
    return recipePostingData.map((data) {
      return FlSpot(
        data['monthIndex'].toDouble(),
        data['count'].toDouble(),
      );
    }).toList();
  }

  // Helper method to calculate max Y value for the chart
  double _calculateMaxY() {
    if (recipePostingData.isEmpty) return 5;
    final maxCount = recipePostingData
        .map((data) => data['count'] as int)
        .reduce((a, b) => a > b ? a : b);
    return maxCount > 0 ? (maxCount + 2).toDouble() : 5;
  }
}

class _StatCardContent extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCardContent({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          _StatCardIcon(icon: icon, color: color),
          const SizedBox(width: 16),
          _StatCardText(title: title, value: value),
        ],
      ),
    );
  }
}

class _StatCardIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _StatCardIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 32,
      ),
    );
  }
}

class _StatCardText extends StatelessWidget {
  final String title;
  final String value;

  const _StatCardText({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A3C34),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}