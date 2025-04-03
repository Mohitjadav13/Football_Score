import 'package:flutter/material.dart';
import '../models/standings.dart';

class StandingCard extends StatelessWidget {
  final TeamStanding standing;

  const StandingCard({Key? key, required this.standing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              standing.rank.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 120,
              child: Text(
                standing.team.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(standing.played.toString()),
            Text('${standing.won}-${standing.draw}-${standing.lost}'),
            Text(
              standing.points.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
