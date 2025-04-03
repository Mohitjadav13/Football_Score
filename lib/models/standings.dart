import 'team.dart';

class TeamStanding {
  final int rank;
  final Team team;
  final int points;
  final int played;
  final int won;
  final int draw;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;

  TeamStanding({
    required this.rank,
    required this.team,
    required this.points,
    required this.played,
    required this.won,
    required this.draw,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(
      rank: json['rank'],
      team: Team.fromJson(json['team']),
      points: json['points'],
      played: json['all']['played'],
      won: json['all']['win'],
      draw: json['all']['draw'],
      lost: json['all']['lose'],
      goalsFor: json['all']['goals']['for'],
      goalsAgainst: json['all']['goals']['against'],
    );
  }

  factory TeamStanding.fromSportsDbJson(Map<String, dynamic> json) {
    return TeamStanding(
      rank: int.parse(json['intRank'] ?? '0'),
      team: Team(
        id: int.parse(json['idTeam'] ?? '0'),
        name: json['strTeam'] ?? 'Unknown',
        logo: json['strTeamBadge'] ?? '',
      ),
      points: int.parse(json['intPoints'] ?? '0'),
      played: int.parse(json['intPlayed'] ?? '0'),
      won: int.parse(json['intWin'] ?? '0'),
      draw: int.parse(json['intDraw'] ?? '0'),
      lost: int.parse(json['intLoss'] ?? '0'),
      goalsFor: int.parse(json['intGoalsFor'] ?? '0'),
      goalsAgainst: int.parse(json['intGoalsAgainst'] ?? '0'),
    );
  }
}
