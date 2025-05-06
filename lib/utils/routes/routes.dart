import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spring_admin/screens/food/food_screen.dart';
import 'package:spring_admin/screens/login/login.dart';
import 'package:spring_admin/screens/new%20entry/face_verification.dart';
import 'package:spring_admin/screens/new%20entry/qr_code_verify.dart';
import 'package:spring_admin/screens/register/register_screen.dart';
import 'package:spring_admin/screens/splash/splash_screen.dart';
// import 'package:spring_admin/screens/registration/quick_registration.dart';

import '../../screens/home/home.dart';
import '../../screens/quick_register.dart';
import '../../screens/settings.dart';
import '../../screens/help.dart';
import '../../screens/guest list/guest_list.dart';
import '../../screens/new entry/new_entry.dart';
import '../../screens/analytics.dart';
import '../../screens/new entry/success.dart';
import '../../screens/guest list/view_guest.dart';
import '../../screens/new entry/manual_entry.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return getPageTransition(HomeScreen(), settings);
      case QuickRegisterScreen.routeName:
        return getPageTransition(QuickRegisterScreen(), settings);
      case SettingsScreen.routeName:
          return getPageTransition(SettingsScreen(), settings);
      case HelpScreen.routeName:
        return getPageTransition(HelpScreen(), settings);
      case GuestListsScreen.routeName:
        return getPageTransition(GuestListsScreen(), settings);
      case NewEntryScreen.routeName:
          return getPageTransition(NewEntryScreen(), settings);
      case AnalyticsScreen.routeName:
        return getPageTransition(AnalyticsScreen(), settings);
      case QrCodeVerifyScreen.routeName:
        return getPageTransition(QrCodeVerifyScreen(), settings);
      case FaceVerificationScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>;
        return getPageTransition(FaceVerificationScreen(
          userId: int.parse(args['userId'] as String),
        ), settings);
      case SuccessScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SuccessScreen());
      case ViewGuestScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ViewGuestScreen(
            userId: args['userId'] as String,
          ),
        );
      case FoodScreen.routeName:
        return getPageTransition(FoodScreen(), settings);
      case ManualEntryScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ManualEntryScreen());
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RegisterScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      // case QuickRegistration.routeName:
      //   return MaterialPageRoute(builder: (_) => const QuickRegistration());
      default:
        return MaterialPageRoute(builder: (_) => Container());
    }
  }

  static getPageTransition(dynamic screenName, RouteSettings setting) {
    return PageTransition(
        child: screenName,
        type: PageTransitionType.theme,
        alignment: Alignment.center,
        settings: setting,
        duration: const Duration(milliseconds: 1000),
        maintainStateData: true,
        curve: Curves.easeInOut);
  }
}
