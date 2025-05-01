import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/providers/camera_settings_provider.dart';
import 'package:spring_admin/screens/camer_capture_screen.dart';
import '../utils/constants/server_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

class QuickRegisterScreen extends StatefulWidget {
  static const String routeName = '/quickRegister';
  const QuickRegisterScreen({super.key});

  @override
  State<QuickRegisterScreen> createState() => _QuickRegisterScreenState();
}

class _QuickRegisterScreenState extends State<QuickRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
 final _contactController = TextEditingController();
 final _instituteController = TextEditingController();
 String visitor_card_path = '';
  // Update ID types map with correct server keys
  // final Map<String, String> _idTypesMap = {
  //   'Aadhar': 'aadhar',
  //   'PAN': 'pan',
  //   'Driving License': 'driving_license',
  //   'Voter ID': 'voter_id',
  //   'Passport': 'passport',
  // };

  // final List<String> _idTypes = [
  //   'Aadhar',
  //   'PAN',
  //   'Driving License',
  //   'Voter ID',
  //   'Passport',
  // ];
  bool isLoading = false;
  String? error;
  // String _selectedUserType = 'individual';
  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraSettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
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
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quick Register',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            bottom: -190,
            left: 150,
            right: -150,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.asset(
                'assets/images/aipen.png',
                height: MediaQuery.of(context).size.height * 0.4,
                color: Color.fromARGB(255, 255, 165, 164),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // _buildHeaderCard(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 8,
                                    ),
                                    child: _buildPhotoSection(cameraProvider),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildInputField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  helperText: "Guest Name",
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter full name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  helperText: "Guest Email Address",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter email address';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  controller: _contactController,
                                  label: 'Contact Number',
                                  helperText: "Enter Contact Number",
                                  icon: Icons.phone,
                                  // maxLength: _selectedIdType == 'Aadhar' ? 12 : 10,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter Contact Number';
                                    }else if(value.length != 10){
                                      return 'Contact Number must be 10 digits';
                                    }
                                    return null;
                                  },
                                ),
                                if (error != null) _buildErrorMessage(),
                               
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                  controller: _instituteController,
                                  label: 'Institute',
                                  helperText: "Enter Institute Name",
                                  icon: Icons.school,
                                ),
                                const SizedBox(height: 16),
                                _buildSubmitButton(cameraProvider),
                                if (visitor_card_path.isNotEmpty)
                                _buildVisitorCard(visitor_card_path),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorCard(String visitorCardPath) {
    return ElevatedButton(
      onPressed: () async {
        try {
          // Normalize the path (replace backslashes with forward slashes)
          final normalizedCardPath = visitorCardPath.replaceAll(r'\', '/');

          // Create the download URL
          final downloadUrl = Uri.parse(
            '${ServerEndpoints.baseUrl}/users/download-visitor-card/?card_path=${Uri.encodeComponent(normalizedCardPath)}',
          );

          // Get app user token for authentication
          final appUserManager = Provider.of<AppUserManager>(
            context,
            listen: false,
          );
          final token = await appUserManager.getAppUserToken();

          // Make the HTTP request
          final response = await http.get(
            downloadUrl,
            headers: {'api-key': token},
          );

          if (response.statusCode == 200) {
            // Get the application documents directory
            final downloadPath = await getApplicationDocumentsDirectory();
            final filePath = '${downloadPath.path}/visitor_card.png';

            // Save the file
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);

            // Open the file
            await OpenFile.open(filePath);

            // Show success message
            Fluttertoast.showToast(
              msg: 'Visitor card downloaded successfully',
              backgroundColor: Colors.green,
            );
          } else {
            throw Exception(
              'Failed to download visitor card: ${response.statusCode}',
            );
          }
        } catch (e) {
          debugPrint('Error downloading visitor card: $e');
          Fluttertoast.showToast(
            msg: 'Error downloading visitor card. Please try again later.',
            backgroundColor: Colors.red,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download, size: 20, color: Colors.white),
          SizedBox(width: 8),
          Text('Download Visitor Card', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        10,
                        128,
                        120,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: Color.fromARGB(255, 10, 128, 120),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Registration',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Register new guest quickly',
                          style: TextStyle(
                            color: Color.fromARGB(255, 10, 128, 120),
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
        ),
      ),
    );
  }

  Widget _buildPhotoSection(CameraSettingsProvider cameraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraCaptureScreen(),
                ),
              );
              setState(() {}); // Refresh UI after returning from camera screen
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child:
                  cameraProvider.capturedImage != null
                      ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(cameraProvider.capturedImage!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                cameraProvider.resetOverlay();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const CameraCaptureScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to capture photo',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color.fromARGB(255, 10, 128, 120),
            ),
            filled: true,
            labelText: helperText,
            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 10, 128, 120),
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }


  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        error!,
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
    );
  }

  Widget _buildSubmitButton(CameraSettingsProvider cameraProvider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleSubmit(cameraProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 10, 128, 120),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Register Guest',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Future<void> _handleSubmit(CameraSettingsProvider cameraProvider) async {
    setState(() {
      error = null;
      isLoading = true;
    });

    try {
      // 1. Validate camera image
      if (cameraProvider.capturedImage == null) {
        throw Exception('Please capture a photo');
      }

      showLoadingDialog(context, "Registering Student...");

      // 4. Get app user details
      final appUserManager = Provider.of<AppUserManager>(
        context,
        listen: false,
      );
      final appUserId = appUserManager.appUserId;
      if (appUserId?.isEmpty ?? true) {
        throw Exception('App user ID not found');
      }
      final appUserToken = await appUserManager.getAppUserToken();

      // 5. Prepare request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerEndpoints.baseUrl}/users/create'),
      );

      // Add form fields
    //    name: str = Form(...),
    // email: str = Form(...),
    // image: UploadFile = File(...),
    // institution_name: str = Form(...),
    // contact_number: str = Form(...),
      request.fields.addAll({
        'name': _nameController.text,
        'email': _emailController.text,
        'contact_number': _contactController.text,
        'institution_name': _instituteController.text,
      });

      // Add headers
      request.headers['api-key'] = appUserToken;

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          cameraProvider.capturedImage!.path,
        ),
      );

      // 6. Send request and handle response
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        if (!mounted) return;
        visitor_card_path = jsonResponse['visitor_card_path'];
        Fluttertoast.showToast(
          msg: 'Guest registered successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Navigator.pop(context); // Close registration screen
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to register guest');
      }
    } catch (e) {
      if (!mounted) return;
      // Navigator.pop(context); // Close any open dialogs
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context); // Close registration screen
      }
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _instituteController.dispose();
    super.dispose();
  }
}


  // Helper method for showing loading dialog
  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 140,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
    );
  }