import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/new%20entry/face_verification.dart';
import 'package:spring_admin/screens/new%20entry/new_entry.dart';
import 'package:spring_admin/screens/quick_register.dart';
import 'dart:convert';
import '../../utils/constants/server_endpoints.dart';

class QrCodeVerifyScreen extends StatefulWidget {
  static const String routeName = '/qrCodeVerify';
  bool? isFood;
  String? mealType;
  QrCodeVerifyScreen({super.key, this.isFood, this.mealType});

  @override
  State<QrCodeVerifyScreen> createState() => _QrCodeVerifyScreenState();
}

class _QrCodeVerifyScreenState extends State<QrCodeVerifyScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;
  String? error;
  bool is_detected = false;
  @override
  Widget build(BuildContext context) {
    Provider.of<AppUserManager>(context, listen: false).setIsScanCompleted(false);
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
             if (is_detected) return;
              setState(() {
                is_detected = true;
              });
              _onDetect(capture);
            },
          ),
          _buildOverlay(),
          if (error != null) _buildErrorOverlay(),
          if (isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (isProcessing || error != null) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    setState(() {
      isProcessing = true; // Prevent multiple scans
    });

    try {
      final Map<String, dynamic> qrData = json.decode(barcodes[0].rawValue.toString());
      debugPrint("Parsed QR data: $qrData");

      final userId = int.parse(qrData['user_id'].toString());
      Provider.of<AppUserManager>(context, listen: false).setCurrentUserId(userId.toString());

      if(widget.isFood == true){
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(ServerEndpoints.scanFood()),
        );
        request.fields['user_id'] = userId.toString();
        request.fields['food_type'] = widget.mealType ?? '';
        final appUserToken = await Provider.of<AppUserManager>(context, listen: false).getAppUserToken();
        if (appUserToken.isEmpty) {
          throw Exception('App user token not found');
        }

        request.headers['api-key'] = appUserToken;
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: 'Food Entry Successful',
            backgroundColor: Colors.green,
          );
          
        } else {
          Fluttertoast.showToast(
            msg: jsonResponse['detail'] ?? 'Food Entry Failed',
            backgroundColor: Colors.red,
          );
        }
        Navigator.of(context).pop();
        showDialog(context: context, builder: (context) => AlertDialog(
          title: Text(response.statusCode == 200 ? 'Food Entry Successful' : 'Food Entry Failed'),
          content: Text(response.statusCode == 200 ? 'Food Entry Successful' : jsonResponse['detail'] ?? 'Food Entry Failed'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
          ],
        ),);
      }else{
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ServerEndpoints.scanQr()),
      );
      request.fields['user_id'] = userId.toString();
      final appUserToken = await Provider.of<AppUserManager>(context, listen: false).getAppUserToken();
      if (appUserToken.isEmpty) {
        throw Exception('App user token not found');
      }
      request.headers['api-key'] = appUserToken;

      // Show loading indicator
      if (!context.mounted) return;
      showLoadingDialog(context, 'Please wait...');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      // Hide loading dialog
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
    Provider.of<AppUserManager>(context, listen: false).setIsFaceCapturedOfCurrentUser(jsonResponse['is_image_captured'] ?? false);
        
      Provider.of<AppUserManager>(context, listen: false).setIsScanCompleted(true);
      if (response.statusCode == 200) {
        Provider.of<AppUserManager>(context, listen: false).setIsBatchRequired(jsonResponse['is_any_entry_exist'] ?? false);

        Fluttertoast.showToast(
          msg: 'Quick Entry Successful',
          backgroundColor: Colors.green,
        );
        
        // Add a small delay to ensure the toast is visible
        
        if (!context.mounted) return;
        // Exit QR screen and return to previous screen
        Navigator.of(context).pop(); // Exit QR screen

      } else {
        Fluttertoast.showToast(
          msg: jsonResponse['detail'] ?? 'Quick Entry Failed',
          backgroundColor: Colors.red,
        );
        // Reset processing state to allow another scan
        setState(() {
          isProcessing = false;
        });
      }}
    } catch (e) {
      // Hide loading dialog if it's showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
      
      // Reset processing state to allow another scan
      setState(() {
        isProcessing = false;
      });
    }
  }

  Widget _buildOverlay() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () => controller.toggleTorch(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios,
                          color: Colors.white),
                      onPressed: () => controller.switchCamera(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Align QR code within the frame to scan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    error = null;
                    controller.start();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Verifying QR Code...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
