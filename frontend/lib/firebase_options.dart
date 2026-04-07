import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart' show TargetPlatform;

/// Configuration for Firebase project
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for fuchsia - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4M30MoxVNssgJC8pQ6_HrST04I980v7M', // Replace with your Android API key
    appId: '1:755496356496:android:5d9f46810d8824af42e615', // Replace with your Android app ID
    messagingSenderId: '755496356496', // Replace with your messaging sender ID
    projectId: 'lagos-dent-v1', // Replace with your project ID
    storageBucket: 'lagos-dent-v1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxxx...', // Replace with your iOS API key
    appId: '1:xxx:ios:xxx', // Replace with your iOS app ID
    messagingSenderId: 'xxx', // Replace with your messaging sender ID
    projectId: 'your-project-id', // Replace with your project ID
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDxxx...', // Replace with your macOS API key
    appId: '1:xxx:macos:xxx', // Replace with your macOS app ID
    messagingSenderId: 'xxx', // Replace with your messaging sender ID
    projectId: 'your-project-id', // Replace with your project ID
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDxxx...', // Replace with your Web API key
    appId: '1:xxx:web:xxx', // Replace with your Web app ID
    messagingSenderId: 'xxx', // Replace with your messaging sender ID
    projectId: 'your-project-id', // Replace with your project ID
    authDomain: 'your-project-id.firebaseapp.com',
    storageBucket: 'your-project-id.appspot.com',
  );
}
