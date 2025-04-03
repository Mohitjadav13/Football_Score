import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static const FirebaseOptions androidOptions = FirebaseOptions(
    apiKey: "AIzaSyD80hElySFAX5JfIp1AP6sk10_dVUVGH98",
    appId: "1:27146344469:android:861a903b3b56b525f2561c",
    messagingSenderId: "27146344469",
    projectId: "onefootball-802fe",
    storageBucket: "onefootball-802fe.firebasestorage.app",
  );

  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: androidOptions,
      );
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
      }
      rethrow;
    }
  }
} 