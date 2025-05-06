import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:spring_admin/utils/constants/server_endpoints.dart';

class AnalyticsScreen extends StatefulWidget {
  static const String routeName = '/analytics';
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? analyticsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      final response = await http.get(Uri.parse(ServerEndpoints.getAnalytics()));
      if (response.statusCode == 200) {
        setState(() {
          analyticsData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFCCCB),
                Color(0xFFFFCCCB).withOpacity(0.6),
                Color(0xFFF5F5F5).withOpacity(0.1)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Analytics',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFCCCB),
                      Color(0xFFFFCCCB).withOpacity(0.6),
                      Color(0xFFF5F5F5).withOpacity(0.1)
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1A237E),
                ),
              )
            else if (analyticsData == null)
              const Center(
                child: Text('Failed to load analytics'),
              )
            else
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Range Card
                    _buildAnalyticsCard(
                      'Analysis Period',
                      Column(
                        children: [
                          _buildStatRow('Start Date', _formatDate(analyticsData!['time_range']['start_date'])),
                          _buildStatRow('End Date', _formatDate(analyticsData!['time_range']['end_date'])),
                          _buildStatRow('Timezone', analyticsData!['time_range']['timezone']),
                        ],
                      ),
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 16),

                    // Overall Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Entries',
                            analyticsData!['overall_statistics']['total_entries'].toString(),
                            Icons.people,
                            Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Unique Users',
                            analyticsData!['overall_statistics']['unique_users'].toString(),
                            Icons.person_outline,
                            Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Overall Metrics Card
                    _buildAnalyticsCard(
                      'Overall Metrics',
                      Column(
                        children: [
                          _buildStatRow(
                            'Average Duration',
                            '${analyticsData!['overall_statistics']['average_duration_minutes'].toStringAsFixed(2)} min'
                          ),
                          _buildStatRow(
                            'Completion Rate',
                            '${analyticsData!['overall_statistics']['completion_rate'].toStringAsFixed(1)}%'
                          ),
                        ],
                      ),
                      Icons.analytics,
                    ),
                    const SizedBox(height: 16),

                    // Traffic Analysis Card
                    _buildAnalyticsCard(
                      'Traffic Analysis',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hourly Distribution',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...(analyticsData!['traffic_analysis']['hourly_distribution'] as Map<String, dynamic>)
                              .entries
                              .map((entry) => _buildTrafficPeriodCard(
                                  '${entry.key}:00',
                                  entry.value as int,
                              ))
                              .toList(),
                          const SizedBox(height: 16),
                          Text(
                            'Peak Hours',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (analyticsData!['traffic_analysis']['peak_hours'] as List)
                                .map((hour) => '$hour:00')
                                .join(', '),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 10, 128, 120),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icons.timeline,
                    ),
                    const SizedBox(height: 16),

                    // Daily Patterns Card
                    _buildAnalyticsCard(
                      'Daily Patterns',
                      Column(
                        children: [
                          ...(analyticsData!['daily_patterns'] as Map<String, dynamic>)
                              .entries
                              .map((entry) => _buildDailyPatternCard(
                                  entry.key,
                                  entry.value as Map<String, dynamic>,
                              ))
                              .toList(),
                        ],
                      ),
                      Icons.calendar_view_day,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, Widget content, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF1A237E)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 10, 128, 120),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficPeriodCard(String period, int totalEntries) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              period,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            Text(
              '$totalEntries entries',
              style: const TextStyle(
                color: Color.fromARGB(255, 10, 128, 120),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPatternCard(String date, Map<String, dynamic> stats) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            'Total Entries',
            stats['total_entries'].toString(),
          ),
          _buildStatRow(
            'Unique Users',
            stats['unique_users'].toString(),
          ),
          _buildStatRow(
            'Average Duration',
            '${stats['average_duration_minutes'].toStringAsFixed(2)} min',
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}
