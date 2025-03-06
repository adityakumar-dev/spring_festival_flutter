import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/providers/camera_settings_provider.dart';
import 'package:spring_admin/screens/camer_capture_screen.dart';
import '../utils/constants/server_endpoints.dart';
import 'package:http/http.dart' as http;

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
  final _uniqueIdController = TextEditingController();
  String _selectedIdType = 'Aadhar'; // Default selection
  
  // Update ID types map with correct server keys
  final Map<String, String> _idTypesMap = {
    'Aadhar': 'aadhar',
    'PAN': 'pan',
    'Driving License': 'driving_license',
    'Voter ID': 'voter_id',
    'Passport': 'passport',
  };
  
  final List<String> _idTypes = ['Aadhar', 'PAN', 'Driving License', 'Voter ID', 'Passport'];
  bool isLoading = false;
  String? error;

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
                Color(0xFFF5F5F5).withOpacity(0.1)
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
                _buildHeaderCard(),
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
                                    side: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildIdTypeSelector(),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  controller: _uniqueIdController,
                                  label: 'ID Number',
                                  helperText: "Enter $_selectedIdType Number",
                                  icon: Icons.credit_card,
                                  // maxLength: _selectedIdType == 'Aadhar' ? 12 : 10,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter $_selectedIdType number';
                                    }
                                    // Validation based on ID type
                                    switch (_selectedIdType) {
                                      case 'Aadhar':
                                        if (value.length != 12) {
                                          return 'Aadhar number must be 12 digits';
                                        }
                                        break;
                                      case 'PAN':
                                        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
                                          return 'Invalid PAN format';
                                        }
                                        break;
                                      case 'Driving License':
                                        if (value.length != 10) {
                                          return 'Driving License number must be 10 digits';
                                        }
                                        break;
                                      case 'Voter ID':
                                        if (value.length != 10) {
                                          return 'Voter ID number must be 10 digits';
                                        }
                                        break;
                                      case 'Passport':
                                        if (value.length != 10) {
                                          return 'Passport number must be 10 digits';
                                        }
                                        break;
                                      // Add other validations as needed
                                    }
                                    return null;
                                  },
                                ),
                                if (error != null) _buildErrorMessage(),
                                const SizedBox(height: 24),
                                _buildSubmitButton(cameraProvider),
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
                      color: const Color.fromARGB(255, 10, 128, 120).withOpacity(0.1),
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
              child: cameraProvider.capturedImage != null
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
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            onPressed: () {
                              cameraProvider.resetOverlay();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CameraCaptureScreen(),
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
            prefixIcon: Icon(icon, color: const Color.fromARGB(255, 10, 128, 120)),
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
              borderSide: const BorderSide(color: Color.fromARGB(255, 10, 128, 120)),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildIdTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ID Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: _idTypes.map((type) => RadioListTile<String>(
              title: Text(type),
              value: type,
              groupValue: _selectedIdType,
              onChanged: (value) {
                setState(() {
                  _selectedIdType = value!;
                  _uniqueIdController.clear(); // Clear the ID field when type changes
                });
              },
              activeColor: const Color.fromARGB(255, 10, 128, 120),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        error!,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
        ),
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
    // if (!_formKey.currentState!.validate()) 
        debugPrint('handleSubmit');

    if (cameraProvider.capturedImage == null) {
      setState(() {
        error = 'Please capture a photo';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://api.vmsbutu.it.com/users/create')
      );
      
      // Add form fields with correct server-side keys
      request.fields['name'] = _nameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['unique_id_type'] = _idTypesMap[_selectedIdType] ?? 'aadhar';
      request.fields['unique_id'] = _uniqueIdController.text;
      request.fields['user_type'] = 'individual';
      final appUserId = Provider.of<AppUserManager>(context, listen: false).appUserId;
      if (appUserId == null || appUserId.isEmpty) {
        throw Exception('App user ID not found');
      }
      request.fields['user_email'] = appUserId;
      request.fields['is_quick_register'] = 'true';
      final appUserToken = await Provider.of<AppUserManager>(context, listen: false).getAppUserToken();
debugPrint('appUserToken: $appUserToken');
request.headers['api-key'] = appUserToken;
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          cameraProvider.capturedImage!.path,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Fluttertoast.showToast(
          msg: 'Guest registered successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to register guest');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
      Fluttertoast.showToast(
        msg: error ?? 'Failed to register guest',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _uniqueIdController.dispose();
    super.dispose();
  }
}