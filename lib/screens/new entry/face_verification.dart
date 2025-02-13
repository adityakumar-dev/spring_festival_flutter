import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:spring_admin/screens/new%20entry/success.dart';
import '../../utils/constants/server_endpoints.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/camera_settings_provider.dart';

class FaceVerificationScreen extends StatefulWidget {
  static const String routeName = '/faceVerification';
  final int userId;

  const FaceVerificationScreen({super.key, required this.userId});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> with WidgetsBindingObserver {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (!mounted) return;
    
    setState(() {
      isInitializing = true;
      error = null;
    });

    try {
      // Release previous controller resources
      await controller?.dispose();
      controller = null;

      cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('No cameras', 'No cameras available on device');
      }

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == 
          (isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => cameras.first,
      );

      final cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Add listener for camera errors
      cameraController.addListener(() {
        if (mounted && cameraController.value.hasError) {
          setState(() {
            error = 'Camera error: ${cameraController.value.errorDescription}';
          });
        }
      });

      // Wait for controller to initialize
      await cameraController.initialize();
      
      if (!mounted) return;
      
      controller = cameraController;

      // Get zoom levels after successful initialization
      await Future.wait([
        cameraController.getMaxZoomLevel().then((value) => maxAvailableZoom = value),
        cameraController.getMinZoomLevel().then((value) => minAvailableZoom = value),
      ]);

      if (!mounted) return;
      
      setState(() {
        isInitializing = false;
      });

    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        isInitializing = false;
        switch (e.code) {
          case 'CameraAccessDenied':
            error = 'You have denied camera access.';
            break;
          default:
            error = 'Camera initialization failed: ${e.description}';
            break;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isInitializing = false;
        error = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _switchCamera() async {
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
    await _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _captureAndVerify() async {
    final cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (cameraController.value.isTakingPicture) return;

    try {
      setState(() {
        isProcessing = true;
        error = null;
      });

      final XFile image = await cameraController.takePicture();
      
      // First verify the face
      final verifyRequest = http.MultipartRequest(
        'POST',
        Uri.parse(ServerEndpoints.verifyFaceRecognition()),
      );
      
      verifyRequest.fields['user_id'] = widget.userId.toString();
      verifyRequest.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );

      final verifyResponse = await verifyRequest.send();
      final verifyData = await verifyResponse.stream.bytesToString();
      final verifyJson = json.decode(verifyData);

      if (verifyResponse.statusCode != 200) {
        throw Exception(verifyJson['error'] ?? 'Failed to verify face');
      }

      final bool isMatch = verifyJson['is_match'] ?? false;
      if (!isMatch) {
        throw Exception('Face verification failed. Please try again.');
      }

      // After successful verification, log/store the face recognition
      // final storeRequest = http.MultipartRequest(
      //   'POST',
      //   Uri.parse(ServerEndpoints.logFaceRecognition()),  // Use existing endpoint
      // );
      
      // storeRequest.fields['user_id'] = widget.userId.toString();
      // storeRequest.files.add(
      //   await http.MultipartFile.fromPath(
      //     'image',
      //     image.path,
      //   ),
      // );

      // final storeResponse = await storeRequest.send();
      // final storeData = await storeResponse.stream.bytesToString();
      // final storeJson = json.decode(storeData);

      // if (storeResponse.statusCode != 200) {
      //   throw Exception(storeJson['error'] ?? 'Failed to store face image');
      // }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, SuccessScreen.routeName);

    } catch (e) {
      setState(() {
        error = e.toString();
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    final cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Camera not initialized',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate the screen and camera ratios
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final scale = deviceRatio * cameraController.value.aspectRatio;

    final baseRotation = Provider.of<CameraSettingsProvider>(context)
        .getRotationAngle(isFrontCamera);
    final cameraRotation = isFrontCamera ? -90 * 3.1415927 / 180 : 90 * 3.1415927 / 180;
    final totalRotation = baseRotation + cameraRotation;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: 1 / scale,
            child: Center(
              child: AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: Transform.rotate(
                  angle: totalRotation,
                  child: CameraPreview(cameraController),
                ),
              ),
            ),
          ),
          _buildOverlay(),
          _buildControls(),
          if (error != null) _buildErrorOverlay(),
          if (isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      size: Size.infinite,
      painter: FaceOverlayPainter(),
    );
  }

  Widget _buildControls() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.rotate_right,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        final provider = Provider.of<CameraSettingsProvider>(
                          context, 
                          listen: false
                        );
                        final currentRotation = provider.getRotationAngle(isFrontCamera);
                        provider.setRotationAngle(
                          currentRotation + (90 * 3.1415927 / 180),
                          isFrontCamera
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _switchCamera,
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
                    'Position your face within the circle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50),
                if (!isProcessing && error == null)
                  FloatingActionButton.large(
                    onPressed: _captureAndVerify,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt,
                      size: 32,
                      color: Colors.black,
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
              'Verifying...',
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }
}

class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw the semi-transparent background
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);

    // Draw the circle outline
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 