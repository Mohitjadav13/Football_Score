import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/football_provider.dart';
import '../providers/news_provider.dart';
import '../providers/standings_provider.dart';

class ProvidersConfig {
  static Widget wrapWithProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FootballProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => StandingsProvider()),
      ],
      child: child,
    );
  }
} 