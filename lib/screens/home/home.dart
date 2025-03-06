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
                Color(0xFFF5F5F5).withOpacity(0.1),
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
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color.fromARGB(255, 10, 128, 120),
                ),
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
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.5,
                            ), // Semi-transparent color overlay
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
                                            255,
                                            10,
                                            128,
                                            120,
                                          ),
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
                    ),
                  ),
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
                  Container(
                    alignment: Alignment.center,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: size.width > 600 ? 3 : 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
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
                            context,
                            GuestListsScreen.routeName,
                          ),
                        ),
                        buildDashboardTile(
                          context,
                          'New Entry',
                          'Add new guest',
                          Icons.person_add_rounded,
                          const Color.fromARGB(255, 52, 55, 95),
                          () => Navigator.pushNamed(
                            context,
                            NewEntryScreen.routeName,
                          ),
                        ),
                        buildDashboardTile(
                          context,
                          'Departure',
                          'Exit the Guest',
                          Icons.exit_to_app_rounded,
                          const Color.fromARGB(255, 52, 55, 95),
                          () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        CustomScanner(operationType: 'exit'),
                              ),
                            );
                          },
                        ),
                        buildDashboardTile(
                          context,
                          'Quick Register',
                          'On-spot registration',
                          Icons.flash_on_rounded,
                          const Color.fromARGB(255, 52, 55, 95),
                          () => Navigator.pushNamed(
                            context,
                            QuickRegisterScreen.routeName,
                          ),
                        ),
                        buildDashboardTile(
                          context,
                          'Analytics',
                          'View statistics',
                          Icons.analytics_rounded,
                          const Color.fromARGB(255, 52, 55, 95),
                          () => Navigator.pushNamed(
                            context,
                            AnalyticsScreen.routeName,
                          ),
                        ),

                        buildDashboardTile(
                          context,
                          'Help',
                          'Support & guides',
                          Icons.help_rounded,
                          const Color.fromARGB(255, 52, 55, 95),
                          () => Navigator.pushNamed(
                            context,
                            HelpScreen.routeName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Logo and University Name Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/utu-logo.png',
                                height: 50,
                                width: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Powered by",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                                  Text(
                                    "VEER MADHO SINGH BHANDARI",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1A237E),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "UTTARAKHAND TECHNICAL UNIVERSITY",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1A237E).withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                      
                        // Divider
                        Divider(
                          color: Color(0xFFFFCCCB).withOpacity(0.5),
                          thickness: 1,
                        ),
                    
                        
                        // Contact info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "P.O. Suddhowala, Dehradun, Uttarakhand",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
