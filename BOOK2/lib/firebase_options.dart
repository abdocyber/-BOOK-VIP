import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWrOZvz3gEFrthzQy8G_7TWa7FF5o5pSs',
    appId: '1:843891799065:android:d787d260db8c2a1bdf6688',
    messagingSenderId: '843891799065',
    projectId: 'book-vip-3e6b8',
    storageBucket: 'book-vip-3e6b8.firebasestorage.app',
  );

  // نفس القيم مؤقتًا عند تشغيل Web/Preview حتى لا يتوقف init.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWrOZvz3gEFrthzQy8G_7TWa7FF5o5pSs',
    appId: '1:843891799065:android:d787d260db8c2a1bdf6688',
    messagingSenderId: '843891799065',
    projectId: 'book-vip-3e6b8',
    storageBucket: 'book-vip-3e6b8.firebasestorage.app',
  );
}
