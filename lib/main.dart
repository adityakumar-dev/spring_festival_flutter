import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spring_admin/firebase_options.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/analytics.dart';
import 'package:spring_admin/screens/guest%20list/guest_list.dart';
import 'package:spring_admin/screens/home/home.dart';
import 'package:spring_admin/screens/new%20entry/face_verification.dart';
import 'package:spring_admin/screens/quick_register.dart';
import 'package:spring_admin/screens/splash/splash_screen.dart';
import 'package:spring_admin/utils/routes/routes.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/camera_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  final prefs = await SharedPreferences.getInstance();
  
  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CameraSettingsProvider(prefs),
        ),
        ChangeNotifierProvider(
          // create: (_) => AppUser(),
          create: (_) => AppUserManager(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: SplashScreen.routeName,
    );
  }
}