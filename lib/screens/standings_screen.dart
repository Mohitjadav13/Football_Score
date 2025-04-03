import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/standings_provider.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({Key? key}) : super(key: key);

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  final List<Map<String, dynamic>> _leagues = [
    {'id': 2021, 'name': 'Premier League'},
    {'id': 2014, 'name': 'La Liga'},
    {'id': 2019, 'name': 'Serie A'},
    {'id': 2002, 'name': 'Bundesliga'},
    {'id': 2015, 'name': 'Ligue 1'},
  ];

  int _selectedLeagueId = 2021;  // Changed default to Premier League ID

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StandingsProvider>().fetchStandings(_selectedLeagueId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StandingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchStandings(_selectedLeagueId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.standings.isEmpty) {
          return const Center(child: Text('No standings data available'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: const [
                    SizedBox(width: 28, child: Text('')),
                    SizedBox(width: 8),
                    Expanded(child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 28, child: Text('P', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 28, child: Text('W', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 28, child: Text('D', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 28, child: Text('L', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 28, child: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.standings.length,
                itemBuilder: (context, index) {
                  final standing = provider.standings[index];
                  final isTop4 = standing.rank <= 4;
                  final isRelegation = standing.rank >= provider.standings.length - 2;

                  return Container(
                    decoration: BoxDecoration(
                      color: isTop4 
                          ? Colors.blue.withOpacity(0.1)
                          : isRelegation 
                              ? Colors.red.withOpacity(0.1)
                              : null,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            standing.rank.toString(),
                            style: TextStyle(
                              fontWeight: isTop4 || isRelegation ? FontWeight.bold : FontWeight.normal,
                              color: isTop4 ? Colors.blue : isRelegation ? Colors.red : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: standing.team.logo,
                                width: 24,
                                height: 24,
                                placeholder: (context, url) => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => 
                                    const Icon(Icons.sports_soccer, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  standing.team.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 28, child: Text(standing.played.toString())),
                        SizedBox(width: 28, child: Text(standing.won.toString())),
                        SizedBox(width: 28, child: Text(standing.draw.toString())),
                        SizedBox(width: 28, child: Text(standing.lost.toString())),
                        SizedBox(
                          width: 28,
                          child: Text(
                            standing.points.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
