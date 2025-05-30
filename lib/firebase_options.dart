// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyANjEFRrrmoIXchtlDyMcF9930q6lWvkN4',
    appId: '1:199589356057:web:fd833c507a430c5f568088',
    messagingSenderId: '199589356057',
    projectId: 'visitor-management-bbd7c',
    authDomain: 'visitor-management-bbd7c.firebaseapp.com',
    databaseURL: 'https://visitor-management-bbd7c-default-rtdb.firebaseio.com',
    storageBucket: 'visitor-management-bbd7c.firebasestorage.app',
    measurementId: 'G-YWXKSTTMWZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA60C0V0IrG3-Eu9OY0Xxc_Bx36dLPPvwc',
    appId: '1:199589356057:android:6122753c25b6b911568088',
    messagingSenderId: '199589356057',
    projectId: 'visitor-management-bbd7c',
    databaseURL: 'https://visitor-management-bbd7c-default-rtdb.firebaseio.com',
    storageBucket: 'visitor-management-bbd7c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQVMFHq2Cbf54VfvBWVvUGCkD58brwba8',
    appId: '1:199589356057:ios:01d13089eafb2076568088',
    messagingSenderId: '199589356057',
    projectId: 'visitor-management-bbd7c',
    databaseURL: 'https://visitor-management-bbd7c-default-rtdb.firebaseio.com',
    storageBucket: 'visitor-management-bbd7c.firebasestorage.app',
    iosBundleId: 'com.example.springAdmin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQVMFHq2Cbf54VfvBWVvUGCkD58brwba8',
    appId: '1:199589356057:ios:01d13089eafb2076568088',
    messagingSenderId: '199589356057',
    projectId: 'visitor-management-bbd7c',
    databaseURL: 'https://visitor-management-bbd7c-default-rtdb.firebaseio.com',
    storageBucket: 'visitor-management-bbd7c.firebasestorage.app',
    iosBundleId: 'com.example.springAdmin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyANjEFRrrmoIXchtlDyMcF9930q6lWvkN4',
    appId: '1:199589356057:web:30110a7a7c9b89a6568088',
    messagingSenderId: '199589356057',
    projectId: 'visitor-management-bbd7c',
    authDomain: 'visitor-management-bbd7c.firebaseapp.com',
    databaseURL: 'https://visitor-management-bbd7c-default-rtdb.firebaseio.com',
    storageBucket: 'visitor-management-bbd7c.firebasestorage.app',
    measurementId: 'G-P7YZWJX1XM',
  );

}