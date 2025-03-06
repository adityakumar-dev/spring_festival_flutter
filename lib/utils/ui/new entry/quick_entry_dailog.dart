import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/utils/constants/server_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:spring_admin/utils/ui/custom_scanner.dart';

class QuickEntryBottomSheet extends StatefulWidget {
  const QuickEntryBottomSheet({super.key});

  @override
  State<QuickEntryBottomSheet> createState() => _QuickEntryBottomSheetState();
}

class _QuickEntryBottomSheetState extends State<QuickEntryBottomSheet> {
  TextEditingController customReasonController = TextEditingController();
  TextEditingController user_id = TextEditingController();

  void showQuickEntryDialog(BuildContext context, String title) async {
    customReasonController.text = title;
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

                // Custom Reason Field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: customReasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: 'Enter reason for bypass entry...',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
                      if (customReasonController.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Please enter reason',
                          backgroundColor: Colors.red,
                        );
                        return;
                      }

                      try {
                        String userId = user_id.text;
                        String custom_reason = customReasonController.text;
                        String app_user_email = Provider.of<AppUserManager>(context, listen: false).appUserId;

                        final request = http.MultipartRequest(
                          'POST',
                          Uri.parse(ServerEndpoints.scanQr()),
                        );
                        request.fields['user_id'] = userId;
                        request.fields['is_bypass'] = 'true';
                        request.fields['bypass_reason'] = custom_reason;
                        request.fields['app_user_email'] = app_user_email;
                        final appUserToken = await Provider.of<AppUserManager>(context, listen: false).getAppUserToken();
                        if (appUserToken == null || appUserToken.isEmpty) {
                          throw Exception('App user token not found');
                        }
                        request.headers['api-key'] = appUserToken;

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        final response = await request.send();
                        // Hide loading indicator
                        Navigator.pop(context);

                        if (response.statusCode == 200) {
                          Fluttertoast.showToast(
                            msg: 'Quick Entry Successful',
                            backgroundColor: Colors.green,
                          );
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Quick Entry Failed',
                            backgroundColor: Colors.red,
                          );
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: 'Error: ${e.toString()}',
                          backgroundColor: Colors.red,
                        );
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Entry',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select reason for quick entry:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickEntryOption(
            context,
            'System Malfunction',
            Icons.error_outline,
          ),
          _buildQuickEntryOption(
            context,
            'Network Issues',
            Icons.wifi_off,
          ),
          _buildQuickEntryOption(
            context,
            'Guest in Hurry',
            Icons.timer,
          ),
          _buildQuickEntryOption(
            context,
            'Other Reason',
            Icons.more_horiz,
           
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickEntryOption(
    BuildContext context,
    String title,
    IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
         showQuickEntryDialog(context, title);
        },
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1a237e)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
