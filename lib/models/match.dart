import 'team.dart';

class Match {
  final int id;
  final Team homeTeam;
  final Team awayTeam;
  final String status;
  final int? homeScore;
  final int? awayScore;
  final String date;
  final Map<String, String>? venue;  // Change type to Map<String, String>

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.status,
    this.homeScore,
    this.awayScore,
    required this.date,
    this.venue,  // Add this parameter
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    try {
      final fixture = json['fixture'];
      final teams = json['teams'];
      final goals = json['goals'] ?? {'home': null, 'away': null};
      
      return Match(
        id: fixture['id'],
        homeTeam: Team.fromJson(teams['home']),
        awayTeam: Team.fromJson(teams['away']),
        status: fixture['status']['long'] ?? 'Unknown',
        homeScore: goals['home'],
        awayScore: goals['away'],
        date: fixture['date'] ?? DateTime.now().toIso8601String(),
        venue: fixture['venue'],  // Add this line
      );
    } catch (e) {
      throw Exception('Error parsing match data: $e');
    }
  }

  factory Match.fromSportsDbJson(Map<String, dynamic> json) {
    try {
      return Match(
        id: int.parse(json['idEvent'] ?? '0'),
        homeTeam: Team(
          id: int.parse(json['idHomeTeam'] ?? '0'),
          name: json['strHomeTeam'] ?? 'Unknown',
          logo: json['strHomeTeamBadge'] ?? '',
        ),
        awayTeam: Team(
          id: int.parse(json['idAwayTeam'] ?? '0'),
          name: json['strAwayTeam'] ?? 'Unknown',
          logo: json['strAwayTeamBadge'] ?? '',
        ),
        status: json['strStatus'] ?? 'Unknown',
        homeScore: int.tryParse(json['intHomeScore'] ?? ''),
        awayScore: int.tryParse(json['intAwayScore'] ?? ''),
        date: json['dateEvent'] ?? DateTime.now().toString(),
        venue: json['strVenue'] != null ? {'name': json['strVenue']} : null,  // Add this line
      );
    } catch (e) {
      throw Exception('Error parsing match data: $e');
    }
  }

  factory Match.fromFotMobJson(Map<String, dynamic> json) {
    try {
      return Match(
        id: json['id'] ?? 0,
        homeTeam: Team(
          id: json['home']['id'] ?? 0,
          name: json['home']['name'] ?? 'Unknown',
          logo: json['home']['logo'] ?? '',
        ),
        awayTeam: Team(
          id: json['away']['id'] ?? 0,
          name: json['away']['name'] ?? 'Unknown',
          logo: json['away']['logo'] ?? '',
        ),
        status: json['status']['label'] ?? 'Unknown',
        homeScore: json['home']['score'],
        awayScore: json['away']['score'],
        date: json['timeStr'] ?? DateTime.now().toString(),
        venue: json['venue'],  // Add this line
      );
    } catch (e) {
      throw Exception('Error parsing FotMob match data: $e');
    }
  }
}
