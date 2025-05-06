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
  final _idController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _countController = TextEditingController();
  String _selectedIdType = 'aadhar';
  String _registrationType = 'individual';
  final List<String> _idTypes = [
    'aadhar',
    'pan',
    'driving_license',
    'voter_id',
    'passport',
  ];
  bool isLoading = false;
  String? error;
  String visitor_card_path = '';

  Widget _buildRegistrationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registration Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _registrationType = 'individual';
                    _groupNameController.clear();
                    _countController.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _registrationType == 'individual'
                        ? const Color.fromARGB(255, 10, 128, 120)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _registrationType == 'individual'
                          ? const Color.fromARGB(255, 10, 128, 120)
                          : Colors.grey.shade200,
                    ),
                    boxShadow: _registrationType == 'individual'
                        ? [
                            BoxShadow(
                              color: const Color.fromARGB(255, 10, 128, 120).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        size: 24,
                        color: _registrationType == 'individual'
                            ? Colors.white
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Individual',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _registrationType == 'individual'
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _registrationType = 'group';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _registrationType == 'group'
                        ? const Color.fromARGB(255, 10, 128, 120)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _registrationType == 'group'
                          ? const Color.fromARGB(255, 10, 128, 120)
                          : Colors.grey.shade200,
                    ),
                    boxShadow: _registrationType == 'group'
                        ? [
                            BoxShadow(
                              color: const Color.fromARGB(255, 10, 128, 120).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.group,
                        size: 24,
                        color: _registrationType == 'group'
                            ? Colors.white
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Group',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _registrationType == 'group'
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdTypeDropdown() {
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
          child: DropdownButtonFormField<String>(
            value: _selectedIdType,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.badge_outlined,
                color: Color.fromARGB(255, 10, 128, 120),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            alignment: AlignmentDirectional.center,
            items: _idTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(color: Colors.grey.shade800),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedIdType = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

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
          SingleChildScrollView(
            child: Column(
              children: [
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
                                _buildRegistrationTypeSelector(),
                                const SizedBox(height: 16),
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
                                _buildIdTypeDropdown(),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  controller: _idController,
                                  label: 'ID Number',
                                  helperText: "Enter ID Number",
                                  icon: Icons.credit_card,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter ID Number';
                                    }
                                    return null;
                                  },
                                ),
                                if (_registrationType == 'group') ...[
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                    controller: _groupNameController,
                                    label: 'Group Name',
                                    helperText: "Enter Group Name",
                                    icon: Icons.group,
                                    validator: (value) {
                                      if (_registrationType == 'group' && 
                                          (value == null || value.trim().isEmpty)) {
                                        return 'Please enter Group Name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                    controller: _countController,
                                    label: 'Count',
                                    helperText: "Enter Count",
                                    icon: Icons.numbers,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (_registrationType == 'group' && 
                                          (value == null || value.trim().isEmpty)) {
                                        return 'Please enter Count';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                if (error != null) _buildErrorMessage(),
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
          final normalizedCardPath = visitorCardPath.replaceAll(r'\', '/');
          final downloadUrl = Uri.parse(
            '${ServerEndpoints.baseUrl}/users/download-visitor-card/?card_path=${Uri.encodeComponent(normalizedCardPath)}',
          );
          final appUserManager = Provider.of<AppUserManager>(
            context,
            listen: false,
          );
          final token = await appUserManager.getAppUserToken();
          final response = await http.get(
            downloadUrl,
            headers: {'api-key': token},
          );

          if (response.statusCode == 200) {
            final downloadPath = await getApplicationDocumentsDirectory();
            final filePath = '${downloadPath.path}/visitor_card.png';
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            await OpenFile.open(filePath);
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
              setState(() {});
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      error = null;
      isLoading = true;
    });

    try {
      if (cameraProvider.capturedImage == null) {
        throw Exception('Please capture a photo');
      }

      showLoadingDialog(context, "Registering Guest...");

      final appUserManager = Provider.of<AppUserManager>(
        context,
        listen: false,
      );
      final appUserId = appUserManager.appUserId;
      if (appUserId?.isEmpty ?? true) {
        throw Exception('App user ID not found');
      }
      final appUserToken = await appUserManager.getAppUserToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerEndpoints.baseUrl}/users/create'),
      );

      final fields = {
        'name': _nameController.text,
        'email': _emailController.text,
        'id_type': _selectedIdType,
        'id': _idController.text,
      };

      if (_registrationType == 'group') {
        fields['group_name'] = _groupNameController.text;
        fields['count'] = _countController.text;
      }

      request.fields.addAll(fields);
      request.headers['api-key'] = appUserToken;
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
        visitor_card_path = jsonResponse['visitor_card_path'];
        Fluttertoast.showToast(
          msg: 'Guest registered successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to register guest');
      }
    } catch (e) {
      if (!mounted) return;
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
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _groupNameController.dispose();
    _countController.dispose();
    super.dispose();
  }
}

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