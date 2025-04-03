import 'package:flutter/material.dart';
import '../models/standings.dart';
import '../services/api_service.dart';

class StandingsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<TeamStanding> _standings = [];
  bool _isLoading = false;
  String? _error;

  List<TeamStanding> get standings => _standings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStandings(int leagueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _standings = await _apiService.getLeagueStandings(leagueId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
