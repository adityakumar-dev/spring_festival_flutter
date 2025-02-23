import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
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
  final _aadharController = TextEditingController();
  bool isLoading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraSettingsProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quick Register',
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
                    Card(
                   color: Colors.white,
                      child: Padding(
                        padding:  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: _buildPhotoSection(cameraProvider),
                      )),
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
                    _buildInputField(
                      controller: _aadharController,
                      label: 'Aadhar Number',
                      helperText: "Guest Aadhar Number",
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter Aadhar number';
                        }
                        if (value.length != 12) {
                          return 'Aadhar number must be 12 digits';
                        }
                        return null;
                      },
                    ),
                    if (error != null) _buildErrorMessage(),
                    const SizedBox(height: 12),
                    _buildSubmitButton(cameraProvider),
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
                  Icons.person_add,
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
                      'Quick Registration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a237e),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Register new guest quickly',
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
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1a237e)),
            filled: true,
            // helperText: helperText,
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
              borderSide: const BorderSide(color: Color(0xFF1a237e)),
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
    if (!_formKey.currentState!.validate()) return;
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

      final request =  http.MultipartRequest('post', Uri.parse(ServerEndpoints.quickRegister()))
       ;
       request.fields['name'] = _nameController.text;
       request.fields['email'] = _emailController.text;
       request.fields['aadhar'] = _aadharController.text;
       request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          cameraProvider.capturedImage!.path,
        ),
      );
    final resposne = await request.send();
      if(resposne.statusCode == 200){
        setState(() {
          isLoading = false;
        });
          // debugPrint(resposne.)
      Fluttertoast.showToast(msg: 'Guest registered successfully');
        Navigator.pop(context);
      }
      Fluttertoast.showToast(msg: 'Failed to register guest');
      // if(request.s)

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
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
    _aadharController.dispose();
    super.dispose();
  }
}