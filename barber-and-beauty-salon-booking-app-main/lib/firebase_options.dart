import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC4NJUzU67kKqgwoVrF_HRqATjYygk2v_Y',
    appId: '1:1093129499249:web:970468dcae65b7887b21d0',
    messagingSenderId: '1093129499249',
    projectId: 'salon-app-b3a76',
    authDomain: 'salon-app-b3a76.firebaseapp.com',
    storageBucket: 'salon-app-b3a76.firebasestorage.app',
    measurementId: 'G-XNMVTXDHP1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBwoFQ1mxcBVJ2NZ3Sb_rRd_m0nJCPIfOU',
    appId: '1:1093129499249:android:8988dde8f9f906867b21d0',
    messagingSenderId: '1093129499249',
    projectId: 'salon-app-b3a76',
    storageBucket: 'salon-app-b3a76.firebasestorage.app',
  );
}
