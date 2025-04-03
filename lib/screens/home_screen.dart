import 'package:flutter/material.dart';
import 'profile/profile_screen.dart';
import 'matches_screen.dart';
import 'news_screen.dart';
import 'standings_screen.dart';
import '../config/styles.dart';
import 'package:provider/provider.dart';
import '../providers/football_provider.dart';
import '../services/api_service.dart';
import '../providers/standings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedLeagueId = 2021;

  final List<Widget> _screens = [
    const MatchesScreen(),
    const NewsScreen(),
    const StandingsScreen(),
    const ProfileScreen(),
  ];

  final List<Map<String, dynamic>> _leagues = [
    {'id': 2021, 'name': 'Premier League'},
    {'id': 2014, 'name': 'La Liga'},
    {'id': 2019, 'name': 'Serie A'},
    {'id': 2002, 'name': 'Bundesliga'},
    {'id': 2015, 'name': 'Ligue 1'},
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.sports_soccer),
      label: 'Matches',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.newspaper),
      label: 'News',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.leaderboard),
      label: 'Standings',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: const Color(0xFF1A237E),
        actions: _buildAppBarActions(context),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF1A237E),
        ),
        child: BottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 14,
          unselectedFontSize: 12,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    // Show competition selector for Matches screen
    if (_selectedIndex == 0) {
      return [
        Consumer<FootballProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.grey[850],
                ),
                child: DropdownButton<int>(
                  value: provider.selectedCompetitionId,
                  underline: Container(),
                  dropdownColor: Colors.grey[850],
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white),
                  items: ApiService.competitions.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      provider.setCompetition(id);
                    }
                  },
                ),
              ),
            );
          },
        ),
        Consumer<FootballProvider>(
          builder: (context, provider, child) {
            if (provider.liveMatches.isNotEmpty) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      provider.fetchMatches();
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        provider.liveMatches.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => provider.fetchMatches(),
            );
          },
        ),
      ];
    }
    
    // Show league selector for Standings screen
    if (_selectedIndex == 2) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.grey[850],
            ),
            child: DropdownButton<int>(
              value: _selectedLeagueId,
              underline: Container(),
              dropdownColor: Colors.grey[850],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white),
              items: _leagues.map((league) {
                return DropdownMenuItem<int>(
                  value: league['id'] as int,
                  child: Text(
                    league['name'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) {
                  setState(() => _selectedLeagueId = id);
                  context.read<StandingsProvider>().fetchStandings(id);
                }
              },
            ),
          ),
        ),
      ];
    }

    return [];
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Matches';
      case 1:
        return 'News';
      case 2:
        return 'Standings';
      case 3:
        return 'Profile';
      default:
        return 'Football App';
    }
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppStyles.mainGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 80,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Football App!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the Profile icon below to view your profile',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}