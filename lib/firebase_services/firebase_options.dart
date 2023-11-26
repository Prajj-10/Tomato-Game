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
/// ```
class DefaultFirebaseOptions {
  /// Returns the default [FirebaseOptions] for the current platform.
  ///
  /// The options are determined based on the platform the Flutter app is running on.
  ///
  /// For web, it returns the [web] options.
  ///
  /// For Android, it returns the [android] options.
  ///
  /// For iOS, it returns the [ios] options.
  ///
  /// For macOS, it returns the [macos] options.
  ///
  /// Throws an [UnsupportedError] for unsupported platforms.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  /// Default Firebase options for the web platform.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA5iFrVFIvmv19OQSHTdqLyhfOCBOShS9A',
    appId: '1:954020304851:web:4082b8f030ce388fa00126',
    messagingSenderId: '954020304851',
    projectId: 'tomato-game',
    authDomain: 'tomato-game.firebaseapp.com',
    storageBucket: 'tomato-game.appspot.com',
    measurementId: 'G-4CXC9FPSTP',
  );

  /// Default Firebase options for the Android platform.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRokDOwwkdIn2bBJYpOCtJ7A8vXpWtrp0',
    appId: '1:954020304851:android:e5d582309dd1d6f0a00126',
    messagingSenderId: '954020304851',
    projectId: 'tomato-game',
    storageBucket: 'tomato-game.appspot.com',
  );

  /// Default Firebase options for the iOS platform.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQAtGCkN3UzYAr-BHoexee-b391rBoZ3A',
    appId: '1:954020304851:ios:dda2b3eecacf8f4da00126',
    messagingSenderId: '954020304851',
    projectId: 'tomato-game',
    storageBucket: 'tomato-game.appspot.com',
    iosBundleId: 'com.cis.tomato.tomatoGame',
  );

  /// Default Firebase options for the macOS platform.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQAtGCkN3UzYAr-BHoexee-b391rBoZ3A',
    appId: '1:954020304851:ios:dda2b3eecacf8f4da00126',
    messagingSenderId: '954020304851',
    projectId: 'tomato-game',
    storageBucket: 'tomato-game.appspot.com',
    iosBundleId: 'com.cis.tomato.tomatoGame',
  );
}
