import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/new%20entry/face_verification.dart';
import 'dart:convert';
import '../../utils/constants/server_endpoints.dart';

class QrCodeVerifyScreen extends StatefulWidget {
  static const String routeName = '/qrCodeVerify';
  const QrCodeVerifyScreen({super.key});

  @override
  State<QrCodeVerifyScreen> createState() => _QrCodeVerifyScreenState();
}

class _QrCodeVerifyScreenState extends State<QrCodeVerifyScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
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

    try {
      setState(() {
        isProcessing = true;
      });

      final String? code = barcodes.first.rawValue;
      if (code == null) {
        throw Exception('Invalid QR Code');
      }

      debugPrint("Raw QR data: $code");
      final Map<String, dynamic> qrData = json.decode(code);
      debugPrint("Parsed QR data: $qrData");

      final userId = int.parse(qrData['user_id'].toString());
      if (userId == null) {
        throw Exception('Invalid QR Code format: Missing or invalid user_id');
      }
      
      final appUserId = Provider.of<AppUserManager>(context, listen: false).appUserId?.toString();
      if (appUserId == null || appUserId.isEmpty) {
        throw Exception('App user ID not found');
      }

      final appUserToken = await Provider.of<AppUserManager>(context, listen: false).getAppUserToken();
      if (appUserToken == null || appUserToken.isEmpty) {
        throw Exception('App user token not found');
      }

      final request = http.MultipartRequest(
        'POST', 
        Uri.parse(ServerEndpoints.scanQr())
      );
      
      request.fields['user_id'] = userId.toString();
      request.fields['app_user_email'] = appUserId;
      request.headers['api-key'] = appUserToken;

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      debugPrint("Response status code: ${streamedResponse.statusCode}");
      debugPrint("Response body: $responseBody");

      if (streamedResponse.statusCode == 200) {
        if (!mounted) return;
       controller.stop();
        Navigator.pushReplacementNamed(
          context,
          FaceVerificationScreen.routeName,
          arguments: {
            'userId': userId,
            'operationType': 'individual',
            'studentIds': null
          },
        );
      } else {
        final responseValue = json.decode(responseBody);
        final errorMessage = responseValue['message'] ?? 'Server error occurred';
        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

    } catch (e) {
      debugPrint('QR Scan error: $e');
      setState(() {
        error = e.toString();
        isProcessing = false;
      });
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
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
