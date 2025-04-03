import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/football_provider.dart';
import '../widgets/match_card.dart';
import '../models/match.dart' as football_match; // Add this import with alias
import '../services/api_service.dart';  // Add this import

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  void _initializeData() async {
    await Future.microtask(() => context.read<FootballProvider>().fetchMatches());
    
    // Switch to Live tab if there are live matches
    if (mounted) {
      final provider = context.read<FootballProvider>();
      if (provider.liveMatches.isNotEmpty && _tabController.index != 0) {
        _tabController.animateTo(0);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Live'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Finished'),
          ],
        ),
        Expanded(
          child: Consumer<FootballProvider>(
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
                      ElevatedButton(
                        onPressed: () => provider.fetchMatches(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildMatchList(provider.liveMatches),
                  _buildMatchList(provider.upcomingMatches),
                  _buildMatchList(provider.finishedMatches),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchList(List<football_match.Match> matches) {
    if (matches.isEmpty) {
      return const Center(child: Text('No matches available'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FootballProvider>().fetchMatches(),
      child: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) => MatchCard(match: matches[index]),
      ),
    );
  }
}
