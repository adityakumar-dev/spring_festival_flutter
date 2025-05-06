import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_admin/apis/local_storage.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/home/home.dart';
import 'package:spring_admin/screens/login/login.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    initUserLogin();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();

    // Navigate after animation completes
    Future.delayed(const Duration(milliseconds: 4000), () {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    });
  }
    initUserLogin() async {
    final appUserManager = Provider.of<AppUserManager>(context, listen: false);
    final allData = await LocalStorageHive.getAllData();

    if (allData['token'] != null && allData['userId'] != null) {
      appUserManager.setAppUserToken(allData['token'] ?? '');
      appUserManager.setAppUserId(allData['userId'] ?? '');
      if (appUserManager.appUserId.isNotEmpty &&
          appUserManager.appUserToken.isNotEmpty) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Positioned.fill(child: Image.asset('assets/images/tahni.jpg', fit: BoxFit.cover,)), 
            //  Text("temp"),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/splash.jpeg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        // App name with scale and fade animation
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/images/emblem.png',
                                      width: 64,
                                      height: 64,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'अभयधीर',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  textAlign: TextAlign.center,
                                  '"Advanced biometric high-security authentication yields dual-layered, highly intelligent recognition"',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        // letterSpacing: 0.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                        // Powered by section with slide up and fade animation
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Powered by',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .shadowColor
                                            .withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/utu-logo.png',
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
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
}
