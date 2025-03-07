import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/new%20entry/success.dart';
import 'package:spring_admin/screens/new%20entry/widgets/error_overlay.dart';
import 'package:spring_admin/screens/new%20entry/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:spring_admin/utils/constants/server_endpoints.dart';
import '../../providers/camera_settings_provider.dart';
import 'widgets/face_overlay_painter.dart';

class FaceVerificationScreen extends StatefulWidget {
  static const String routeName = '/faceVerification';
  final int userId;
  final String operationType;
final List<int>? studentIds;
  const FaceVerificationScreen({super.key, required this.userId, required this.operationType, this.studentIds});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> with WidgetsBindingObserver {
  CameraSettingsProvider? cameraProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cameraProvider = Provider.of<CameraSettingsProvider>(context, listen: false);

    // Initialize camera after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cameraProvider?.initCamera();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
   
    if (cameraProvider == null || !cameraProvider!.controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraProvider!.disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      cameraProvider!.initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraSettingsProvider>(
      builder: (context, provider, child) {
        if (provider.isInitializing) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        final cameraController = provider.controller;

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
                    onPressed: () => provider.initCamera(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final size = MediaQuery.of(context).size;
      final deviceRatio = size.width / size.height;
        // Modify the scale calculation to better fit the screen
        final scale = 1.5 / (deviceRatio * cameraController.value.aspectRatio);


        // Calculate total rotation
        final baseRotation = provider.getRotationAngle();
        final cameraRotation = provider.isFrontCamera ? 
            -90 * (3.1415927 / 180) : 
            90 * (3.1415927 / 180);
        final totalRotation = baseRotation + cameraRotation;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: scale,
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
              _buildControls(provider),
              if (provider.error != null) 
                buildErrorOverlay(provider.error!, () => provider.resetOverlay(), ()async{
                   String userId = widget.userId.toString();
                        String custom_reason =  "Face Verification Failed, verification bypassed";
                        String app_user_email = Provider.of<AppUserManager>(context, listen: false).appUserId;

                        final request = http.MultipartRequest(
                          'POST',
                          Uri.parse(ServerEndpoints.scanQr()),
                        );
                        request.fields['user_id'] = userId;
                        request.fields['is_bypass'] = 'true';
                        request.fields['bypass_reason'] = custom_reason;
                        request.fields['app_user_email'] = app_user_email;
                        final appUserToken = await Provider.of<AppUserManager>(context, listen: false).getAppUserToken();
                        if (appUserToken == null || appUserToken.isEmpty) {
                          throw Exception('App user token not found');
                        }
                        request.headers['api-key'] = appUserToken;

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        final response = await request.send();
                        // Hide loading indicator
                        Navigator.pop(context);

                        if (response.statusCode == 200) {
                          Navigator.pushNamed(context, SuccessScreen.routeName);
                          } else {
                            provider.resetOverlay();
                            provider.error = "Face Verification Failed, verification bypassed";

                            // provider.setError("Face Verification Failed, verification bypassed");
                        }
                } ),
              if (provider.isProcessing) buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      size: Size.infinite,
      painter: FaceOverlayPainter(),
    );
  }

  Widget _buildControls(CameraSettingsProvider provider) {
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
                      icon: const Icon(
                        Icons.rotate_right,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => provider.setRotationAngle(),
                    ),
                    IconButton(
                      icon: Icon(
                        provider.isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => provider.changeCamera(),
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
                if (!provider.isProcessing && provider.error == null)
                  FloatingActionButton.large(
                    onPressed: () { 
                      // provider.setIsProcessing(false);
                      provider.captureAndVerify(context, widget.userId.toString(), widget.operationType, widget.studentIds);
                      // provider.setIsProcessing(false);
                    },
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
