import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/api_service.dart';

class FootballProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Match> _matches = [];
  bool _isLoading = false;
  String? _error;
  int _selectedCompetitionId = 2021;

  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedCompetitionId => _selectedCompetitionId;

  List<Match> get liveMatches => 
    _matches.where((m) => 
      m.status.toLowerCase() == 'live' || 
      m.status.toLowerCase() == 'in play' ||
      m.status.toLowerCase() == 'playing'
    ).toList();
  
  List<Match> get upcomingMatches => 
    _matches.where((m) => 
      (m.status.toLowerCase() == 'upcoming' || 
       m.status.toLowerCase() == 'scheduled' ||
       m.status.toLowerCase() == 'today') &&
      DateTime.parse(m.date).isAfter(DateTime.now())
    )
    .toList()
    ..sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date))); // Sort by date ascending
  
  List<Match> get finishedMatches => 
    _matches.where((m) => 
      m.status.toLowerCase() == 'finished' || 
      m.status.toLowerCase() == 'ft' ||
      m.status.toLowerCase() == 'full-time'
    )
    .toList()
    ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date))); // Sort by date descending

  Future<void> fetchMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matches = await _apiService.getMatches(competitionId: _selectedCompetitionId);
      // Check for live matches and notify listeners
      if (liveMatches.isNotEmpty) {
        // Refresh more frequently when there are live matches
        _startLiveUpdates();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startLiveUpdates() {
    // Refresh data every 60 seconds for live matches
    Future.delayed(const Duration(seconds: 60), () {
      if (liveMatches.isNotEmpty) {
        fetchMatches();
      }
    });
  }

  void setCompetition(int id) {
    _selectedCompetitionId = id;
    fetchMatches();
  }
}
