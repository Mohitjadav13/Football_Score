import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'config/app_init.dart';
import 'config/providers_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    // Initialize app configurations
    await AppInit.initialize();
    
    // Run app with providers
    runApp(
      ProvidersConfig.wrapWithProviders(
        child: const App(),
      ),
    );
  } catch (e) {
    debugPrint('Error starting app: $e');
    rethrow;
  }
}
