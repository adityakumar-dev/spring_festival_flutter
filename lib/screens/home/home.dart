import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:spring_admin/apis/firebase_controller.dart';
import 'package:spring_admin/screens/home/dashboard_title.dart';
import 'package:spring_admin/screens/analytics.dart';
import 'package:spring_admin/screens/settings.dart';
import 'package:spring_admin/screens/help.dart';
import 'package:spring_admin/screens/guest%20list/guest_list.dart';
import 'package:spring_admin/screens/new%20entry/new_entry.dart';
import 'package:spring_admin/screens/quick_register.dart';
import 'dart:ui';

import 'package:spring_admin/utils/ui/custom_scanner.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFCCCB),
                Color(0xFFF5F5F5),
                Color(0xFFF5F5F5).withOpacity(0.1)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/emblem.png',
                  height: 45,
                  color: const Color.fromARGB(255, 3, 7, 61),
                ),
                const SizedBox(width: 12),
                const Column(
                  children: [
                    Text(
                      'SPRING FESTIVAL 2025',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: const Color(0xFF1A237E),
                      ),
                    ),
                    Text(
                      'Security Portal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 10, 128, 120),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Color.fromARGB(255, 10, 128, 120)),
                onPressed: () {
                  // Handle notifications
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
        Positioned(
            bottom: -190,
            left: 150,
            right: -150,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.asset(
                'assets/images/aipen.png',
                // width: ,
                height: MediaQuery.of(context).size.height * 0.4,
                color: Color.fromARGB(255, 255, 165, 164),
              ),
            ),
          ),
            // Positioned(
            //   top: -190,
            //   right: 150,
            //   left: -150,
            //   child: Container(
            //     height: MediaQuery.of(context).size.height * 0.4,
            //     width: double.infinity,
            //     child: Image.asset(
            //       'assets/images/aipen3.png',
            //       height: MediaQuery.of(context).size.height * 0.4,
            //       width: double.infinity,
            //       fit: BoxFit.contain,
            //     ),
            //   ),
            // ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                                0.5), // Semi-transparent color overlay
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  child: const Icon(
                                    Icons.security,
                                    color: Color.fromARGB(255, 10, 128, 120),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(
                                        'Welcome, Security',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 10, 128, 120),
                                        ),
                                      ),
                                    ]))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  // Uncomment and customize the following Text widget as needed
                  // Text(
                  //   'Today: 150 Guests | 45 Pending Entries',
                  //   style: TextStyle(
                  //     color: Color(0xFF666666),
                  //     fontSize: 14,
                  //   ),
                  // ),
      
                  // Quick Stats
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: _buildStatCard(
                  //           'Active Guests',
                  //           '120',
                  //           Icons.people,
                  //           Colors.green,
                  //         ),
                  //       ),
                  //       const SizedBox(width: 12),
                  //       Expanded(
                  //         child: _buildStatCard(
                  //           'Pending Approvals',
                  //           '45',
                  //           Icons.pending_actions,
                  //           Colors.orange,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
      
                  // Main Features
                  ,
                  //  Align(
                  //    alignment: Alignment.center,
                  //    child: ClipRRect(
                  //          borderRadius: BorderRadius.circular(12),
                  //          child: BackdropFilter(
                  //            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  //            child: Container(
                  //              decoration: BoxDecoration(
                  //                color: Colors.white.withOpacity(0.2),
                  //                borderRadius: BorderRadius.circular(12),
                  //              ),
                  //              padding: const EdgeInsets.all(16),
                  //              child: const Text(
                  //                'Main Features',
                  //                style: TextStyle(
                  //                  fontSize: 18,
                  //                  fontWeight: FontWeight.bold,
                  //                  color: Color.fromARGB(255, 10, 128, 120),
                  //                ),
                  //              ),
                  //            ),
                  //          ),
                  //        ),
                  //  ),
      
                  // Dashboard Grid
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: size.width > 600 ? 3 : 2,
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
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
                        () => Navigator.pushNamed(
                            context, GuestListsScreen.routeName),
                      ),
                      buildDashboardTile(
                        context,
                        'New Entry',
                        'Add new guest',
                        Icons.person_add_rounded,
                        const Color.fromARGB(255, 52, 55, 95),
                        () => Navigator.pushNamed(
                            context, NewEntryScreen.routeName),
                      ),
                       buildDashboardTile(
                        context,
                        'Departure',
                        'Exit the Guest',
                        Icons.exit_to_app_rounded,
                        const Color.fromARGB(255, 52, 55, 95),
                        () async{
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CustomScanner(operationType: 'exit')));
                        },
                      ),
                      buildDashboardTile(
                        context,
                        'Quick Register',
                        'On-spot registration',
                        Icons.flash_on_rounded,
                        const Color.fromARGB(255, 52, 55, 95),
                        () => Navigator.pushNamed(
                            context, QuickRegisterScreen.routeName),
                      ),
                      buildDashboardTile(
                        context,
                        'Analytics',
                        'View statistics',
                        Icons.analytics_rounded,
                        const Color.fromARGB(255, 52, 55, 95),
                        () => Navigator.pushNamed(
                            context, AnalyticsScreen.routeName),
                      ),
                      // buildDashboardTile(
                      //   context,
                      //   'Settings',
                      //   'App preferences',
                      //   Icons.settings_rounded,
                      //   const Color.fromARGB(255, 52, 55, 95),
                      //   () => Navigator.pushNamed(
                      //       context, SettingsScreen.routeName),
                      // ),
                      buildDashboardTile(
                        context,
                        'Help',
                        'Support & guides',
                        Icons.help_rounded,
                        const Color.fromARGB(255, 52, 55, 95),
                        () => Navigator.pushNamed(
                            context, HelpScreen.routeName),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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

// ```language:lib/screens/home/home.dart
  Widget _buildRecentActivityList() {
    // Stream`` stream = FirebaseController.ref.child('activity').onValue;
    return StreamBuilder(
      stream: FirebaseController.ref.child('events').onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          // Get the entries from the snapshot
          final entries =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final lastEntry = entries.values.last; // Get the last entry

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
              title: Text(lastEntry['user_name'] ??
                  'User'), // Use the message from the last entry
              subtitle: Text(lastEntry['type'] == 'face_verification'
                  ? lastEntry['matched']
                      ? 'Face Verification Successful'
                      : 'Face Verification Failed'
                  : lastEntry['message'] ??
                      'Message'), // Use the timestamp from the last entry
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Handle activity tap
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
