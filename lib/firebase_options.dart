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
    apiKey: 'AIzaSyCziSd0HzO6DjLFjDm765OGWfeO5jkLvHA',
    appId: '1:381053516514:web:ffde460f60e9f0f1dffcbb',
    messagingSenderId: '381053516514',
    projectId: 'dailypulse-f7220',
    authDomain: 'dailypulse-f7220.firebaseapp.com',
    storageBucket: 'dailypulse-f7220.firebasestorage.app',
    measurementId: 'G-93VRYRRX8H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQVQf4-VLwn7t_WPy-rKDN0SZny7Q5ijI',
    appId: '1:381053516514:android:4e532e38cb7e4b6bdffcbb',
    messagingSenderId: '381053516514',
    projectId: 'dailypulse-f7220',
    storageBucket: 'dailypulse-f7220.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBilBYMdCVTOEuN53ZI5Juxy0SOSunw9cY',
    appId: '1:381053516514:ios:077b81bcbb937dbddffcbb',
    messagingSenderId: '381053516514',
    projectId: 'dailypulse-f7220',
    storageBucket: 'dailypulse-f7220.firebasestorage.app',
    iosBundleId: 'com.example.dailypulse',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBilBYMdCVTOEuN53ZI5Juxy0SOSunw9cY',
    appId: '1:381053516514:ios:077b81bcbb937dbddffcbb',
    messagingSenderId: '381053516514',
    projectId: 'dailypulse-f7220',
    storageBucket: 'dailypulse-f7220.firebasestorage.app',
    iosBundleId: 'com.example.dailypulse',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCziSd0HzO6DjLFjDm765OGWfeO5jkLvHA',
    appId: '1:381053516514:web:c7085b3ecd95fe50dffcbb',
    messagingSenderId: '381053516514',
    projectId: 'dailypulse-f7220',
    authDomain: 'dailypulse-f7220.firebaseapp.com',
    storageBucket: 'dailypulse-f7220.firebasestorage.app',
    measurementId: 'G-G8VKTD8FL4',
  );
}
