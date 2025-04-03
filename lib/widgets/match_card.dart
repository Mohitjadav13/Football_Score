import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match.dart';
import '../models/team.dart';  // Make sure this import is correct
import '../screens/match_details_screen.dart';

class MatchCard extends StatelessWidget {
  final Match match;

  const MatchCard({Key? key, required this.match}) : super(key: key);

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
      
      return '$dayText\n$hour:$minute $period';
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.green;
      case 'finished':
        return Colors.grey;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFinished = match.status.toLowerCase() == 'finished' || 
                      match.status.toLowerCase() == 'ft' ||
                      match.status.toLowerCase() == 'full-time';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailsScreen(match: match),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade900.withOpacity(0.1),
                Colors.blue.shade500.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTeam(match.homeTeam),
                    ),
                    Expanded(
                      flex: 4,
                      child: match.status.toLowerCase() == 'live' || isFinished
                        ? _buildScoreDisplay()
                        : _buildDateTimeDisplay(),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildTeam(match.awayTeam),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(match.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        match.status,
                        style: TextStyle(
                          color: _getStatusColor(match.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isFinished)
                      Text(
                        '${_getFormattedDate(match.date).split('\n')[0]} • ${_getFormattedDate(match.date).split('\n')[1]}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeDisplay() {
    if (match.status.toLowerCase() == 'upcoming' || 
        match.status.toLowerCase() == 'scheduled' ||
        match.status.toLowerCase() == 'today') {
      final dateParts = _getFormattedDate(match.date).split('\n');
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dateParts[0], // "Today", "Tomorrow" or date
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateParts[1].split(' ')[0], // Time
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                dateParts[1].split(' ')[1], // AM/PM
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildScoreDisplay() {
    return Text(
      '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTeam(Team team) {  // This should now work correctly with the proper import
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: team.logo.isEmpty ? 'https://via.placeholder.com/30' : team.logo,
          width: 40,
          height: 40,
          placeholder: (context, url) => const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.sports_soccer,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          team.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
