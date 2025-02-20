import 'package:flutter/material.dart';
import 'package:spring_admin/screens/home/dashboard_title.dart';
import 'package:spring_admin/screens/analytics.dart'; 
import 'package:spring_admin/screens/settings.dart';
import 'package:spring_admin/screens/help.dart';
import 'package:spring_admin/screens/guest%20list/guest_list.dart';
import 'package:spring_admin/screens/new%20entry/new_entry.dart';
import 'package:spring_admin/screens/quick_register.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final padding = MediaQuery.of(context).padding;
    // final availableHeight = size.height - padding.top - padding.bottom;
    
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/emblem.png',
              height: 45,
              color: const Color(0xFF1a237e),
            ),
            const SizedBox(width: 12),
            const Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPRING Festival',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xFF1a237e),
                  ),
                ),
                Text(
                  'Security Portal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1a237e)),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFF1a237e).withOpacity(0.1),
                          child: const Icon(
                            Icons.security,
                            color: Color(0xFF1a237e),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, Security',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1a237e),
                                ),
                              ),
                              Text(
                                'Today: 150 Guests | 45 Pending Entries',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active Guests',
                        '120',
                        Icons.people,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending Approvals',
                        '45',
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Features
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Main Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                ),
              ),
              
              // Dashboard Grid
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: size.width > 600 ? 3 : 2,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                crossAxisSpacing: size.width * 0.04,
                mainAxisSpacing: size.height * 0.02,
                childAspectRatio: size.width > 600 ? 1.3 : 1.1,
                children: [
                  buildDashboardTile(
                    context,
                    'Guest List',
                    'View & manage guests',
                    Icons.people_alt_rounded,
                    const Color.fromARGB(255, 52, 55, 95),
                    () => Navigator.pushNamed(context, GuestListsScreen.routeName),
                  ),
                  buildDashboardTile(
                    context,
                    'New Entry',
                    'Add new guest',
                    Icons.person_add_rounded,
                    const Color.fromARGB(255, 52, 55, 95),
                    () => Navigator.pushNamed(context, NewEntryScreen.routeName),
                  ),
                  buildDashboardTile(
                    context,
                    'Quick Register',
                    'On-spot registration',
                    Icons.flash_on_rounded,
                    const Color.fromARGB(255, 52, 55, 95),
                    () => Navigator.pushNamed(context, QuickRegisterScreen.routeName),
                  ),
                  buildDashboardTile(
                    context,
                    'Analytics',
                    'View statistics',
                    Icons.analytics_rounded,
                    const Color.fromARGB(255, 52, 55, 95),
                    () => Navigator.pushNamed(context, AnalyticsScreen.routeName),
                  ),
                  buildDashboardTile(
                    context,
                    'Settings',
                    'App preferences',
                    Icons.settings_rounded,
                    const Color.fromARGB(255, 52, 55, 95),
                    () => Navigator.pushNamed(context, SettingsScreen.routeName),
                  ),
                  buildDashboardTile(
                    context,
                    'Help',
                    'Support & guides',
                    Icons.help_rounded,
                      const Color.fromARGB(255, 52, 55, 95),
                    () => Navigator.pushNamed(context, HelpScreen.routeName),
                  ),
                ],
              ),
              
              // Recent Activity
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                ),
              ),
              _buildRecentActivityList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      color: Colors.white,
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
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

  Widget _buildRecentActivityList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1a237e).withOpacity(0.1),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF1a237e),
              ),
            ),
            title: const Text('Guest Entry Approved'),
            subtitle: Text('2 minutes ago'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle activity tap
            },
          ),
        );
      },
    );
  }
}