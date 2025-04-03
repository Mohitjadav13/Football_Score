import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match.dart';
import '../models/news.dart';
import '../models/standings.dart';
import '../models/team.dart';

class ApiService {
  static const String baseUrl = 'https://api.football-data.org/v4';
  static const String apiKey = 'ca07d7923cec49e089d5aa1de129dd0a';
  static const String newsApiKey = '48a2ad44dd984700abb4d264a38eaf25';  // Updated NewsAPI key

  static const Map<int, String> competitions = {
    2021: 'Premier League',
    2014: 'La Liga',
    2019: 'Serie A',
    2002: 'Bundesliga',
    2015: 'Ligue 1',
  };

  static const Map<int, Map<String, String>> leagueVenues = {
    2021: {'name': 'Premier League Stadium', 'city': 'England'},
    2014: {'name': 'La Liga Stadium', 'city': 'Spain'},
    2019: {'name': 'Serie A Stadium', 'city': 'Italy'},
    2002: {'name': 'Bundesliga Stadium', 'city': 'Germany'},
    2015: {'name': 'Ligue 1 Stadium', 'city': 'France'},
  };

  String _getTeamLogo(Map<String, dynamic> teamData) {
    final crest = teamData['crest'];
    if (crest != null && crest.toString().isNotEmpty) {
      return crest;
    }
    final logo = teamData['logo'];
    if (logo != null && logo.toString().isNotEmpty) {
      return logo;
    }
    return 'https://resources.premierleague.com/premierleague/badges/default.png';
  }

  String _getShortTeamName(String fullName) {
    // Common words to remove
    final wordsToRemove = ['FC', 'CF', 'AFC', 'United', '& Hove Albion', 'Hotspur'];
    
    String shortName = fullName;
    for (var word in wordsToRemove) {
      shortName = shortName.replaceAll(word, '').trim();
    }
    
    // Special cases
    final specialCases = {
      'Manchester City': 'Man City',
      'Manchester': 'Man Utd',
      'Newcastle': 'Newcastle',
      'Brighton': 'Brighton',
      'Wolverhampton Wanderers': 'Wolves',
      'Tottenham': 'Spurs',
      'Sheffield': 'Sheffield Utd',
    };
    
    for (var entry in specialCases.entries) {
      if (shortName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return shortName;
  }

  Future<List<Match>> getMatches({int competitionId = 2021}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions/$competitionId/matches?status=SCHEDULED,LIVE,FINISHED'),
        headers: {
          'X-Auth-Token': apiKey,
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final matches = data['matches'] as List;
        final now = DateTime.now();

        return matches.map((match) {
          final matchDate = DateTime.parse(match['utcDate']).toLocal();

          String status;
          if (match['status'] == 'FINISHED') {
            status = 'Finished';
          } else if (match['status'] == 'LIVE') {
            status = 'Live';
          } else {
            final isToday = matchDate.year == now.year &&
                           matchDate.month == now.month &&
                           matchDate.day == now.day &&
                           matchDate.isAfter(now);

            status = isToday ? 'Today' : 'Upcoming';
          }

          final homeTeamName = match['homeTeam']['name'] ?? 'Unknown';
          final awayTeamName = match['awayTeam']['name'] ?? 'Unknown';
          
          print('Home Team: $homeTeamName');
          print('Away Team: $awayTeamName');
          
          final homeLogo = _getTeamLogo(match['homeTeam']);
          final awayLogo = _getTeamLogo(match['awayTeam']);
          
          print('Home Logo: $homeLogo');
          print('Away Logo: $awayLogo');

          return Match(
            id: match['id'],
            homeTeam: Team(
              id: match['homeTeam']['id'],
              name: homeTeamName,
              logo: homeLogo,
            ),
            awayTeam: Team(
              id: match['awayTeam']['id'],
              name: awayTeamName,
              logo: awayLogo,
            ),
            status: status,
            homeScore: match['score']['fullTime']['home'],
            awayScore: match['score']['fullTime']['away'],
            date: DateTime.parse(match['utcDate']).toLocal().toString(),
            venue: match['venue'] ?? leagueVenues[competitionId] ?? {'name': 'Stadium', 'city': 'Unknown'},
          );
        }).toList();
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
      throw Exception('Failed to load matches: $e');
    }
  }

  Future<List<TeamStanding>> getLeagueStandings(int leagueId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions/$leagueId/standings'),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final standings = data['standings'][0]['table'] as List;
        
        return standings.map<TeamStanding>((standing) {
          final fullName = standing['team']['name'];
          final shortName = _getShortTeamName(fullName);
          
          return TeamStanding(
            rank: standing['position'],
            team: Team(
              id: standing['team']['id'],
              name: shortName,
              logo: _getTeamLogo(standing['team']),
            ),
            points: standing['points'],
            played: standing['playedGames'],
            won: standing['won'],
            draw: standing['draw'],
            lost: standing['lost'],
            goalsFor: standing['goalsFor'],
            goalsAgainst: standing['goalsAgainst'],
          );
        }).toList();
      } else {
        throw Exception('Failed to load standings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching standings: $e');
      throw Exception('Failed to load standings');
    }
  }

  Future<List<NewsArticle>> getNews() async {
    try {
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/everything?q=football&language=en&pageSize=20&sortBy=publishedAt&apiKey=$newsApiKey'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        
        return articles.map((article) => NewsArticle(
          title: article['title'] ?? '',
          description: article['description'] ?? '',
          // Clean up content by removing character limit indicator
          content: article['content']?.toString().replaceAll(RegExp(r'\[\+\d+ chars]'), '') ?? '',
          image: article['urlToImage'] ?? '',
          url: article['url'] ?? '',
          source: article['source']?['name'] ?? '',
          author: article['author'] ?? 'Unknown',
          publishedAt: article['publishedAt'] ?? DateTime.now().toIso8601String(),
        )).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
      throw Exception('Failed to load news');
    }
  }

  Future<Map<String, dynamic>> getMatchDetails(int matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matches/$matchId'),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Print venue data for debugging
        print('Venue data: ${data['match']['venue']}');
        return data;
      } else {
        throw Exception('Failed to load match details');
      }
    } catch (e) {
      print('Error fetching match details: $e');
      throw Exception('Failed to load match details');
    }
  }

  Future<Map<String, dynamic>> getMatchStats(Match match) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matches/${match.id}'),
        headers: {'X-Auth-Token': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stats = data['match']['statistics'] ?? {};
        
        return {
          'Ball Possession': {
            'home': stats['possession']?['home']?.toString() ?? '50',
            'away': stats['possession']?['away']?.toString() ?? '50',
          },
          'Total Shots': {
            'home': stats['shots']?['total']?['home']?.toString() ?? '12',
            'away': stats['shots']?['total']?['away']?.toString() ?? '10',
          },
          'Shots on Target': {
            'home': stats['shots']?['onGoal']?['home']?.toString() ?? '5',
            'away': stats['shots']?['onGoal']?['away']?.toString() ?? '4',
          },
          'Corner Kicks': {
            'home': stats['corners']?['home']?.toString() ?? '6',
            'away': stats['corners']?['away']?.toString() ?? '5',
          },
          'Fouls': {
            'home': stats['fouls']?['home']?.toString() ?? '12',
            'away': stats['fouls']?['away']?.toString() ?? '14',
          },
          'Yellow Cards': {
            'home': stats['cards']?['yellow']?['home']?.toString() ?? '2',
            'away': stats['cards']?['yellow']?['away']?.toString() ?? '3',
          },
          'Red Cards': {
            'home': stats['cards']?['red']?['home']?.toString() ?? '0',
            'away': stats['cards']?['red']?['away']?.toString() ?? '0',
          },
          'Offsides': {
            'home': stats['offsides']?['home']?.toString() ?? '2',
            'away': stats['offsides']?['away']?.toString() ?? '3',
          },
          'Passes': {
            'home': stats['passes']?['total']?['home']?.toString() ?? '450',
            'away': stats['passes']?['total']?['away']?.toString() ?? '425',
          },
          'Pass Accuracy': {
            'home': stats['passes']?['accuracy']?['home']?.toString() ?? '85',
            'away': stats['passes']?['accuracy']?['away']?.toString() ?? '82',
          },
        };
      }
      
      return _getDefaultStats(match);
    } catch (e) {
      print('Error fetching match stats: $e');
      return _getDefaultStats(match);
    }
  }

  Map<String, dynamic> _getDefaultStats(Match match) {
    final isHomeWinning = (match.homeScore ?? 0) > (match.awayScore ?? 0);
    
    return {
      'Ball Possession': {
        'home': isHomeWinning ? '55' : '45',
        'away': isHomeWinning ? '45' : '55',
      },
      'Total Shots': {
        'home': isHomeWinning ? '15' : '10',
        'away': isHomeWinning ? '8' : '12',
      },
      'Shots on Target': {
        'home': isHomeWinning ? '7' : '4',
        'away': isHomeWinning ? '3' : '6',
      },
      'Corner Kicks': {
        'home': '6',
        'away': '5',
      },
      'Fouls': {
        'home': '12',
        'away': '14',
      },
      'Yellow Cards': {
        'home': '2',
        'away': '3',
      },
      'Red Cards': {
        'home': '0',
        'away': '0',
      },
      'Offsides': {
        'home': '2',
        'away': '3',
      },
      'Passes': {
        'home': '450',
        'away': '425',
      },
      'Pass Accuracy': {
        'home': '85',
        'away': '82',
      },
    };
  }
}
