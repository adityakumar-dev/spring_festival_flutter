import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:spring_admin/apis/firebase_controller.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/new%20entry/success.dart';
import 'package:spring_admin/utils/constants/server_endpoints.dart';
import 'dart:convert';

class CameraSettingsProvider extends ChangeNotifier {
  static const String _frontCameraRotationKey = 'front_camera_rotation_angle';
  static const String _backCameraRotationKey = 'back_camera_rotation_angle';
  final SharedPreferences _prefs;

  double _frontCameraRotation = 0.0;
  double _backCameraRotation = 0.0;
  CameraController? controller;
  bool isProcessing = false;
  String? error;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentScale = 1.0;
  double baseScale = 1.0;
  bool isFrontCamera = false;
  List<CameraDescription> cameras = [];
  bool isInitializing = true;
  XFile? capturedImage;

  void resetOverlay() {
    error = null;
    isProcessing = false;
    capturedImage = null;
    notifyListeners();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Select the appropriate camera based on isFrontCamera flag
      final selectedCamera = cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            (isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => cameras.first,
      );

      // Create and initialize the controller
      controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      controller!.addListener(() {
        if (controller!.value.hasError) {
          error = 'Camera error: ${controller!.value.errorDescription}';
          notifyListeners();
        }
      });

      await controller!.initialize();
      minAvailableZoom = await controller!.getMinZoomLevel();
      maxAvailableZoom = await controller!.getMaxZoomLevel();
      baseScale = controller!.value.aspectRatio;
      isInitializing = false;

      notifyListeners();
    } catch (e) {
      error = 'Failed to initialize camera: $e';
      isInitializing = false;
      notifyListeners();
    }
  }

  void disposeCamera() async {
    await controller!.dispose();
    controller = null;
    notifyListeners();
  }

  Future<void> changeCamera() async {
    try {
      isInitializing = true;
      notifyListeners();

      // Properly dispose of the current controller
      if (controller != null) {
        await controller!.dispose();
        controller = null;
      }

      // Toggle camera direction
      isFrontCamera = !isFrontCamera;

      // Initialize with new camera
      await initCamera();
    } catch (e) {
      error = 'Failed to switch camera: $e';
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> captureImage() async {
    if (controller == null) {
      return;
    }
    try {
      capturedImage = await controller!.takePicture();
      notifyListeners();
    } catch (e) {
      error = 'Failed to capture image: $e';
      Fluttertoast.showToast(msg: error!);
      isProcessing = false;
      notifyListeners();
    }
  }

  setIsProcessing(bool value) {
    isProcessing = value;
    notifyListeners();
  }

  Future<void> captureAndVerify(
    BuildContext context,
    String userId,
   
  ) async {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    if (controller!.value.isTakingPicture) return;

    try {
      isProcessing = true;
      notifyListeners();
      
      await captureImage();
      isProcessing = false;
      final XFile image = capturedImage!;
      //process the image on the server and go back to the previous screen run on the background
      //close the dialog
      Navigator.pop(context);
      //close the screen
      Navigator.pop(context);

      final request = http.MultipartRequest('POST', Uri.parse(ServerEndpoints.captureFace()));
      request.fields['user_id'] = userId;
      request.files.add(http.MultipartFile.fromBytes('file', await image.readAsBytes(), filename: image.name));
      request.headers['api-key'] = Provider.of<AppUserManager>(context, listen: false).appUserToken;
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      if(response.statusCode == 200){
        Fluttertoast.showToast(msg: 'Face Capture Success');
        isProcessing = false;
        // Navigator.pushReplacementNamed(context, SuccessScreen.routeName);
      }else{
        debugPrint(jsonResponse.toString());
        print(jsonResponse.toString());
        Fluttertoast.showToast(msg: jsonResponse['detail']);
        error = jsonResponse['detail'];
        isProcessing = false;
        notifyListeners();
      }
    } catch (e) {
      
      isProcessing = false;
      notifyListeners();
    }
  }

  CameraSettingsProvider(this._prefs)
    : _frontCameraRotation = _prefs.getDouble(_frontCameraRotationKey) ?? 0.0,
      _backCameraRotation = _prefs.getDouble(_backCameraRotationKey) ?? 0.0;

  double getRotationAngle() {
    // Convert stored degrees to radians
    final degrees = isFrontCamera ? _frontCameraRotation : _backCameraRotation;
    return degrees * (3.1415927 / 180); // Convert to radians
  }

  Future<void> setRotationAngle() async {
    try {
      if (isFrontCamera) {
        _frontCameraRotation = (_frontCameraRotation + 90) % 360;
        await _prefs.setDouble(_frontCameraRotationKey, _frontCameraRotation);
      } else {
        _backCameraRotation = (_backCameraRotation + 90) % 360;
        await _prefs.setDouble(_backCameraRotationKey, _backCameraRotation);
      }
      notifyListeners();
    } catch (e) {
      print("Rotation error: $e");
    }
  }
}
