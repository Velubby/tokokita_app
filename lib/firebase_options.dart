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
    apiKey: 'AIzaSyDZ5IF3u6RTuLV6fc5X41SL7gp-s_TpVZE',
    appId: '1:576851441251:web:2940648c60cebb37206a56',
    messagingSenderId: '576851441251',
    projectId: 'tokokita-app-4a3d2',
    authDomain: 'tokokita-app-4a3d2.firebaseapp.com',
    storageBucket: 'tokokita-app-4a3d2.firebasestorage.app',
    measurementId: 'G-F9LJQFL6DQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmYZ60pA-xZh0AgMovhFYp-PPsFJRKx48',
    appId: '1:576851441251:android:478b8c1d8169ae99206a56',
    messagingSenderId: '576851441251',
    projectId: 'tokokita-app-4a3d2',
    storageBucket: 'tokokita-app-4a3d2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAvIt7OPuo7X4bqVLlI4AB2-mu_Ua162mo',
    appId: '1:576851441251:ios:17ce5b24740973c6206a56',
    messagingSenderId: '576851441251',
    projectId: 'tokokita-app-4a3d2',
    storageBucket: 'tokokita-app-4a3d2.firebasestorage.app',
    iosBundleId: 'com.example.tokokitaApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAvIt7OPuo7X4bqVLlI4AB2-mu_Ua162mo',
    appId: '1:576851441251:ios:17ce5b24740973c6206a56',
    messagingSenderId: '576851441251',
    projectId: 'tokokita-app-4a3d2',
    storageBucket: 'tokokita-app-4a3d2.firebasestorage.app',
    iosBundleId: 'com.example.tokokitaApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZ5IF3u6RTuLV6fc5X41SL7gp-s_TpVZE',
    appId: '1:576851441251:web:6de6c400a7fdc35a206a56',
    messagingSenderId: '576851441251',
    projectId: 'tokokita-app-4a3d2',
    authDomain: 'tokokita-app-4a3d2.firebaseapp.com',
    storageBucket: 'tokokita-app-4a3d2.firebasestorage.app',
    measurementId: 'G-M9X8JTECMQ',
  );
}