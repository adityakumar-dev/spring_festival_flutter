import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:spring_admin/apis/local_storage.dart';
import 'package:spring_admin/screens/login/login.dart';
import 'package:spring_admin/screens/quick_register.dart';
import 'package:spring_admin/utils/constants/server_endpoints.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _profilePicture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 10, 128, 120),
                Color.fromARGB(255, 5, 100, 100),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            title: Text(
              "Register Your Account",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.check, color: Colors.white),
                onPressed: () async {
                  if (_adminNameController.text.isEmpty ||
                      _adminPasswordController.text.isEmpty ||
                      _usernameController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _emailController.text.isEmpty) {
                    Fluttertoast.showToast(msg: "Please fill all the fields", backgroundColor: Colors.red, textColor: Colors.white);
                  } else if (_profilePicture == null) {
                    Fluttertoast.showToast(msg: "Please upload your profile picture", backgroundColor: Colors.red, textColor: Colors.white);
                  } else {
                   await _handleRegister();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              inputTextfield("Username", Icons.person_outline_rounded, _usernameController, isFocused: true, readOnly: false),
              const SizedBox(height: 10),
              inputTextfield("Password", Icons.lock_outline_rounded, _passwordController, isPassword: true, readOnly: false),
              const SizedBox(height: 10),
              inputTextfield("Email", Icons.email_outlined, _emailController, readOnly: false),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Text(
                  "Profile Picture",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () {
                  ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
                    setState(() {
                      if (value != null) {
                        _profilePicture = File(value.path);
                      }
                    });
                  });
                },
                title: Text(
                  _profilePicture == null ? "Please upload your profile picture" : _profilePicture!.path.split('/').last,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                leading: _profilePicture == null ? Icon(Icons.person_outline_rounded) : Image.file(_profilePicture!),
              ),
              const SizedBox(height: 10),
              inputTextfield("Admin Name", Icons.person_outline_rounded, _adminNameController, readOnly: false),
              const SizedBox(height: 10),
              inputTextfield("Admin Password", Icons.lock_outline_rounded, _adminPasswordController, isPassword: true, readOnly: false),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    showLoadingDialog(context, "Registering...");

    final request = http.MultipartRequest('POST', Uri.parse(ServerEndpoints.registerUser()));
    request.fields['admin_name'] = _adminNameController.text.trim();
    request.fields['admin_password'] = _adminPasswordController.text.trim();
    request.fields['user_name'] = _usernameController.text.trim();
    request.fields['user_password'] = _passwordController.text.trim();
    request.fields['user_email'] = _emailController.text.trim();

    if (_profilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', _profilePicture!.path));
    }

    try {
      final response = await request.send();
      final responseStr = await response.stream.bytesToString();
      final data = jsonDecode(responseStr);

      if (response.statusCode == 200 && data["status"] == true) {
        Fluttertoast.showToast(msg: "Registration successful", backgroundColor: Colors.green, textColor: Colors.white);
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Registration failed", backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occurred: $e", backgroundColor: Colors.red, textColor: Colors.white);
    } finally {
      Navigator.pop(context);
    }
  }
}