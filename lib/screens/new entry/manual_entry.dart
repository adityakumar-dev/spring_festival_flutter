import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/new%20entry/face_verification.dart';
import 'dart:convert';
import '../../utils/constants/server_endpoints.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ManualEntryScreen extends StatefulWidget {
  static const String routeName = '/manual_entry';
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  bool isLoading = false;
  String? error;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      debugPrint("Submitting form with user ID: ${_userIdController.text}");
      
      // Parse user ID to integer
      final userId = int.parse(_userIdController.text.trim());
      
      final appUserToken = await Provider.of<AppUserManager>(context, listen: false).getAppUserToken();
      if (appUserToken == null || appUserToken.isEmpty) {
        throw Exception('App user token not found');
      }

      final request = http.MultipartRequest(
        'POST', 
        Uri.parse('${ServerEndpoints.scanQr()}')
      ); 
      request.fields['user_id'] = userId.toString();
      request.fields['app_user_email'] = Provider.of<AppUserManager>(context, listen: false).appUserId;
      request.headers['api-key'] = appUserToken;
      
      // Send request and get response
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      
      debugPrint("Response status: ${streamedResponse.statusCode}");
      debugPrint("Response body: $responseBody");

      if (!mounted) return;

      if (streamedResponse.statusCode == 200) {
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
        setState(() {
          error = errorMessage;
        });
        _showErrorOverlay();
      }
    } catch (e) {
      debugPrint("Error during submission: $e");
      final errorMessage = 'Error: ${e.toString()}';
      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        error = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => buildErrorOverlay(),
    );
  }

  Widget buildErrorOverlay() {
    return WillPopScope(
      onWillPop: () async => false,  // Prevent back button dismissal
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verification Failed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error ?? 'An unknown error occurred',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close overlay
                        _userIdController.clear(); // Clear the input
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close overlay
                        Navigator.of(context).pop(); // Go back to previous screen
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manual Entry',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                 
                    _buildUserIdField(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                                        const SizedBox(height: 24),

                       _buildInstructionsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        color: const Color(0xFFF8F9FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a237e).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_search,
                  color: Color(0xFF1a237e),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a237e),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Enter guest ID to proceed',
                      style: TextStyle(
                        color: Color(0xFF424242),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF1a237e).withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: const Color(0xFF1a237e).withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Please enter the guest\'s User ID to verify their identity',
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User ID',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _userIdController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter User ID',
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1a237e)),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1a237e)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter User ID';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1a237e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Verify Guest',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}