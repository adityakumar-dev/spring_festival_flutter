import 'package:flutter/material.dart';
import 'package:spring_admin/screens/home/dashboard_title.dart';
import 'package:spring_admin/screens/analytics.dart'; 
import 'package:spring_admin/screens/settings.dart';
import 'package:spring_admin/screens/help.dart';
import 'package:spring_admin/screens/guest_list.dart';
import 'package:spring_admin/screens/new_entry.dart';
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
    // Get screen size
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    
    // Calculate available height
    final availableHeight = size.height - padding.top - padding.bottom;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Container(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Color(0xFF2C3E50),
          //     Color(0xFF3498DB),
          //   ],
          // ),
          color: Colors.white
        ),
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine grid layout based on screen size
                final crossAxisCount = size.width > 600 ? 3 : 2;
                final childAspectRatio = size.width > 600 ? 1.3 : 1.1;
                
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,  // Responsive padding
                      vertical: availableHeight * 0.02,
                    ),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: constraints.maxWidth * 0.04,  // Responsive spacing
                      mainAxisSpacing: constraints.maxHeight * 0.02,
                      childAspectRatio: childAspectRatio,
                      children: [
                        buildDashboardTile(
                          context,
                          'Guest List',
                          'View & manage guests',
                          Icons.people_alt_rounded,
                          const Color(0xFF27AE60),
                          () => Navigator.pushNamed(context, GuestListsScreen.routeName),
                        ),
                        buildDashboardTile(
                          context,
                          'New Entry',
                          'Add new guest',
                          Icons.person_add_rounded,
                          const Color(0xFF9B59B6),
                          () => Navigator.pushNamed(context, NewEntryScreen.routeName),
                        ),
                        buildDashboardTile(
                          context,
                          'Quick Register',
                          'On-spot registration',
                          Icons.flash_on_rounded,
                          const Color(0xFFE74C3C),
                          () => Navigator.pushNamed(context, QuickRegisterScreen.routeName),
                        ),
                        buildDashboardTile(
                          context,
                          'Analytics',
                          'View statistics',
                          Icons.analytics_rounded,
                          const Color(0xFFF39C12),
                          () => Navigator.pushNamed(context, AnalyticsScreen.routeName),
                        ),
                        buildDashboardTile(
                          context,
                          'Settings',
                          'System preferences',
                          Icons.settings_rounded,
                          const Color(0xFF34495E),
                          () => Navigator.pushNamed(context, SettingsScreen.routeName),
                        ),
                        buildDashboardTile(
                          context,
                          'Help',
                          'Support & guides',
                          Icons.help_rounded,
                          const Color(0xFF16A085),
                          () => Navigator.pushNamed(context, HelpScreen.routeName),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}