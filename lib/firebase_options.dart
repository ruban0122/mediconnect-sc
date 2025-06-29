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
    apiKey: 'AIzaSyB5kjUaHiVs25okgtzKsjQTjbqYvsfqd5A',
    appId: '1:21294923692:web:583bbee6d611f2c5f2c409',
    messagingSenderId: '21294923692',
    projectId: 'mediconnect-d8af0',
    authDomain: 'mediconnect-d8af0.firebaseapp.com',
    storageBucket: 'mediconnect-d8af0.firebasestorage.app',
    measurementId: 'G-QDKS3Y5KPD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYJk-fKDDsFLEgUJQ2Hm2rvhK-58iaWyQ',
    appId: '1:21294923692:android:2f2a1c02ae5056a1f2c409',
    messagingSenderId: '21294923692',
    projectId: 'mediconnect-d8af0',
    storageBucket: 'mediconnect-d8af0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1tGVxxI2p-mlzKKqq4J6dHI-_zQ7swto',
    appId: '1:21294923692:ios:16553a138265d573f2c409',
    messagingSenderId: '21294923692',
    projectId: 'mediconnect-d8af0',
    storageBucket: 'mediconnect-d8af0.firebasestorage.app',
    iosBundleId: 'com.example.mediconnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB1tGVxxI2p-mlzKKqq4J6dHI-_zQ7swto',
    appId: '1:21294923692:ios:16553a138265d573f2c409',
    messagingSenderId: '21294923692',
    projectId: 'mediconnect-d8af0',
    storageBucket: 'mediconnect-d8af0.firebasestorage.app',
    iosBundleId: 'com.example.mediconnect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB5kjUaHiVs25okgtzKsjQTjbqYvsfqd5A',
    appId: '1:21294923692:web:10134373ecffefa9f2c409',
    messagingSenderId: '21294923692',
    projectId: 'mediconnect-d8af0',
    authDomain: 'mediconnect-d8af0.firebaseapp.com',
    storageBucket: 'mediconnect-d8af0.firebasestorage.app',
    measurementId: 'G-FXPTBQMGX1',
  );
}
