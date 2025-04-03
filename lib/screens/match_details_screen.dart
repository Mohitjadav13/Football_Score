import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../services/api_service.dart';  // Add this import
import 'package:cached_network_image/cached_network_image.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;

  const MatchDetailsScreen({Key? key, required this.match}) : super(key: key);

  @override
  _MatchDetailsScreenState createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final ApiService _apiService = ApiService();  // Create instance as class field

  @override
  void initState() {
    super.initState();
  }

  String _getFormattedDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      
      String dayText;
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dayText = 'Today';
      } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
        dayText = 'Tomorrow';
      } else {
        dayText = '${date.day}/${date.month}/${date.year}';
      }

      // Format time in 12-hour format with AM/PM
      int hour = date.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : hour;
      hour = hour == 0 ? 12 : hour;
      String minute = date.minute.toString().padLeft(2, '0');
      
      return '$dayText $hour:$minute $period';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = widget.match.status.toLowerCase() == 'upcoming' ||
                      widget.match.status.toLowerCase() == 'scheduled' ||
                      widget.match.status.toLowerCase() == 'today';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMatchHeader(),
            if (!isUpcoming) _buildMatchStats(),
            _buildGameInformation(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade700],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 160, // Increased from 132 to 160 to accommodate content
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: widget.match.homeTeam.logo.isEmpty 
                                ? 'https://via.placeholder.com/100' 
                                : widget.match.homeTeam.logo,
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.match.homeTeam.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40), // Adjust to align with badges
                      child: _buildScoreBox(),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: widget.match.awayTeam.logo.isEmpty 
                                ? 'https://via.placeholder.com/100' 
                                : widget.match.awayTeam.logo,
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.match.awayTeam.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.match.status.toLowerCase() == 'upcoming' || 
              widget.match.status.toLowerCase() == 'scheduled')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.match.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameInformation() {
    final venue = widget.match.venue ?? {'name': 'Unknown Venue', 'city': ''};
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Game Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            'Competition',
            'Premier League',
            Icons.emoji_events,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            'Kick-off',
            _getFormattedDate(widget.match.date).split('\n').join(' '),
            Icons.access_time,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            'Stadium',
            venue['city']?.isNotEmpty ?? false
                ? '${venue['name']} • ${venue['city']}'
                : venue['name'] ?? 'Unknown Venue',
            Icons.stadium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreBox() {
    final isUpcoming = widget.match.status.toLowerCase() == 'upcoming' || 
                      widget.match.status.toLowerCase() == 'scheduled' ||
                      widget.match.status.toLowerCase() == 'today';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isUpcoming)
            Column(
              children: [
                Text(
                  _getFormattedDate(widget.match.date).split(' ')[0], // Day
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getFormattedDate(widget.match.date).split(' ')[1], // Time
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFormattedDate(widget.match.date).split(' ')[2], // AM/PM
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else if (!isUpcoming)  // Only show score for non-upcoming matches
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.match.homeScore ?? 0}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.match.awayScore ?? 0}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchStats() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Get stats from API and build stat rows dynamically
          FutureBuilder<Map<String, dynamic>>(
            future: _apiService.getMatchStats(widget.match),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.hasError) {
                return const Center(child: Text('No statistics available'));
              }

              final stats = snapshot.data!;
              return Column(
                children: stats.entries.map((stat) {
                  final homeValue = double.tryParse(stat.value['home'].toString()) ?? 0;
                  final awayValue = double.tryParse(stat.value['away'].toString()) ?? 0;
                  return _buildStatRow(
                    stat.key,
                    stat.value['home'].toString(),
                    stat.value['away'].toString(),
                    homeValue,
                    awayValue,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String home, String away, double homeValue, double awayValue) {
    // Add % sign for specific stats
    final shouldAddPercent = title == 'Ball Possession' || title == 'Pass Accuracy';
    final homeText = shouldAddPercent ? '$home%' : home;
    final awayText = shouldAddPercent ? '$away%' : away;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (homeValue > awayValue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      homeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    homeText,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (awayValue > homeValue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      awayText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    awayText,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(Team team) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center, // Add this
      children: [
        SizedBox(
          height: 60,
          child: Center( // Center the image
            child: CachedNetworkImage(
              imageUrl: team.logo.isEmpty 
                  ? 'https://via.placeholder.com/100' 
                  : team.logo,
              width: 60,
              height: 60,
              placeholder: (context, url) => const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.sports_soccer,
                size: 60,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
