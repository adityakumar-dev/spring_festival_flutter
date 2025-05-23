import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/new%20entry/face_verification.dart';
import 'package:spring_admin/screens/new%20entry/group_entry/studentlist.dart';
import 'package:spring_admin/screens/quick_register.dart';
import 'package:spring_admin/utils/constants/server_endpoints.dart';
import 'package:spring_admin/utils/ui/custom_scanner.dart';

// Update the color constants at the top
const Color primaryColor = Color.fromARGB(255, 10, 128, 120);
const Color secondaryColor = Color.fromARGB(216, 126, 212, 207);
const Color secondaryTextColor = Color(0xFF757575);
const Color cardBgColor = Color(0xFFF8F9FC);
const Color accentGreen = Color(0xFF43A047);
const Color accentOrange = Color(0xFFFB8C00);
const Color accentRed = Color(0xFFE53935);

class NewEntryScreen extends StatelessWidget {
  static const String routeName = '/newEntry';

  const NewEntryScreen({super.key});

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A237E)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'New Entry',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background decorative elements
          Positioned(
            bottom: -190,
            right: 150,
            left: -150,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4 - 20,
              child: Image.asset(
                'assets/images/aipen.png',
                height: MediaQuery.of(context).size.height * 0.4 - 20,
                color: Color.fromARGB(255, 255, 165, 164),
              ),
            ),
          ),
          // Positioned(
          //   top: -190,
          //   left: 150,
          //   right: -150,
          //   child: Image.asset(
          //     'assets/images/aipen3.png',
          //     height: MediaQuery.of(context).size.height * 0.8,
          //     fit: BoxFit.contain,
          //   ),
          // ),
          // // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildHeaderCard(),
                // _buildQuickStats(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(10),
                      //   child: BackdropFilter(
                      //     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      //     child: Container(
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: 8,
                      //         vertical: 4,
                      //       ),
                      //       decoration: BoxDecoration(
                      //         color: Colors.white.withOpacity(0.2),
                      //       ),
                      //       child: Column(
                      //         children: [
                      //           // _buildSectionWithHelp('Standard Entry Methods'),
                      //           const SizedBox(height: 16),
                      //           const _StandardEntryOptions(),
                      //           const SizedBox(height: 32),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // _buildSectionWithHelp('Special Entry Methods'),
                      const SizedBox(height: 16),
                      const _SpecialEntryOptions(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildHeaderCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(12),
  //       child: BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: const Icon(
  //                   Icons.how_to_reg,
  //                   color: primaryColor,
  //                   size: 32,
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //               const Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Guest Entry',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                         color: primaryColor,
  //                       ),
  //                     ),
  //                     SizedBox(height: 4),
  //                     Text(
  //                       'Select an entry method below',
  //                       style: TextStyle(
  //                         color: secondaryTextColor,
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildQuickStats() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: _buildStatItem(
  //             'Today\'s Entries',
  //             '45',
  //             Icons.today,
  //             accentGreen,
  //           ),
  //         ),
  //         Expanded(
  //           child: _buildStatItem(
  //             'Pending',
  //             '12',
  //             Icons.pending_actions,
  //             accentOrange,
  //           ),
  //         ),
  //         Expanded(
  //           child: _buildStatItem(
  //             'Emergency',
  //             '2',
  //             Icons.warning_rounded,
  //             accentRed,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatItem(
  //   String label,
  //   String value,
  //   IconData icon,
  //   Color color,
  // ) {
  //   return Card(
  //     elevation: 0,
  //     color: color.withOpacity(0.08),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       side: BorderSide(color: color.withOpacity(0.2)),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
  //       child: Column(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: color.withOpacity(0.1),
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(icon, color: color, size: 20),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             value,
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: color,
  //             ),
  //           ),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //               color: color.withOpacity(0.8),
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSectionWithHelp(String title) {
  //   return Row(
  //     children: [
  //       Text(
  //         title,
  //         style: const TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: Color(0xFF1a237e),
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       Tooltip(
  //         message: 'Tap for more information',
  //         child: IconButton(
  //           icon: const Icon(
  //             Icons.help_outline,
  //             size: 18,
  //             color: Color(0xFF1a237e),
  //           ),
  //           onPressed: () {
  //             // Show help dialog
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

}

// class _StandardEntryOptions extends StatelessWidget {
//   const _StandardEntryOptions();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildOptionCard(
//           'QR Code + Face Recognition',
//           'Standard verification process',
//           Icons.qr_code_scanner,
//           const Color(0xFF1a237e),
//           () => Navigator.pushNamed(context, QrCodeVerifyScreen.routeName),
//         ),
//         const SizedBox(height: 12),
//         _buildOptionCard(
//           'Manual ID Entry + Face',
//           'Enter guest ID manually',
//           Icons.person_search,
//           const Color(0xFF1a237e),
//           () => Navigator.pushNamed(context, ManualEntryScreen.routeName),
//         ),
//       ],
//     );
//   }
// }

class _SpecialEntryOptions extends StatefulWidget {
  const _SpecialEntryOptions();

  @override
  State<_SpecialEntryOptions> createState() => _SpecialEntryOptionsState();
}

class _SpecialEntryOptionsState extends State<_SpecialEntryOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOptionCard(
          'Quick Entry',
          'Scan QR Code',
          Icons.flash_on,
          const Color(0xFF1a237e),
          () {
            showQuickEntryDialog(context, 'Bypass verification with reason', setState);
          },
        ),
        const SizedBox(height: 12),
        
        // const SizedBox(height: 12),
        // _buildOptionCard(
        //   'Emergency Entry',
        //   'Immediate access with logging',
        //   Icons.warning_rounded,
        //   const Color(0xFF1a237e),
        //   () => showEmergencyEntryDialog(context),
        // ),
      ],
    );
  }

}

// First, create a new StatefulWidget for the bottom sheet
class GroupEntryBottomSheet extends StatefulWidget {
  const GroupEntryBottomSheet({super.key});

  @override
  State<GroupEntryBottomSheet> createState() => _GroupEntryBottomSheetState();
}

class _GroupEntryBottomSheetState extends State<GroupEntryBottomSheet> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group Entry',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: cardBgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomScanner(operationType: 'entry'),
                    ),
                  );
                  
                  if (result != null) {
                    setState(() {
                      controller.text = result.toString();
                    });
                    Fluttertoast.showToast(msg: 'Id is : $result');
                  }
                },
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: primaryColor,
                ),
              ),
              hintText: 'Enter user ID',
              hintStyle: const TextStyle(color: secondaryTextColor),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentListScreen(
                      userId: controller.text,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

Widget _buildOptionCard(
  String title,
  String subtitle,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return Card(
    elevation: 2,
    color: cardBgColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
          ],
        ),
      ),
    ),
  );
}


  void showQuickEntryDialog(BuildContext context, String title, Function setState) async {
TextEditingController user_id = TextEditingController();
// TextEditingController customReasonController = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Entry Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // User ID Field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: user_id,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      // ali
                      hintStyle: const TextStyle(color: Colors.grey, ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      hintText: 'Enter App User ID',
                      suffixIcon: IconButton(
                        onPressed: () async {
                          Navigator.push<String>(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => CustomScanner(operationType: 'entry')
                            )
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                user_id.text = value;
                              });
                              Fluttertoast.showToast(
                                msg: 'User ID loaded successfully',
                                backgroundColor: Colors.green,
                              );
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),


                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (user_id.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Please enter User ID',
                          backgroundColor: Colors.red,
                        );
                        return;
                      }
                    
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

void showFaceCaptureDialog(BuildContext context, String userId, String title, Function setState) async {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 10, 128, 120)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
                Text(
                  "Face Not Captured, please capture your face!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (userId.isNotEmpty && int.tryParse(userId) != null) {
                        Navigator.pushNamed(
                          context,
                          FaceVerificationScreen.routeName,
                          arguments: {
                            'userId': int.tryParse(userId) ?? 0,
                          },
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: 'User ID is invalid',
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 10, 128, 120),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Capture Face", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Cancel", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}