import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

class AppInit {
  static Future<void> initialize() async {
    try {
      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await FirebaseConfig.initializeFirebase();

      // Set preferred orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      debugPrint('Error initializing app: $e');
      rethrow;
    }
  }
} 