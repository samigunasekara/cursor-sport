import 'package:flutter/material.dart';
import 'sport_events_page.dart';

class MoreSportsPage extends StatelessWidget {
  const MoreSportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of all sports with their icons, alphabetically ordered
    final List<Map<String, dynamic>> sports = [
      {'name': 'Badminton', 'icon': Icons.sports_handball},
      {'name': 'Baseball', 'icon': Icons.sports_baseball},
      {'name': 'Basketball', 'icon': Icons.sports_basketball},
      {'name': 'Boxing', 'icon': Icons.sports_mma},
      {'name': 'Cricket', 'icon': Icons.sports_cricket},
      {'name': 'Cycling', 'icon': Icons.directions_bike},
      {'name': 'Football', 'icon': Icons.sports_soccer},
      {'name': 'Golf', 'icon': Icons.sports_golf},
      {'name': 'Gymnastics', 'icon': Icons.sports_gymnastics},
      {'name': 'Ice Hockey', 'icon': Icons.sports_hockey},
      {'name': 'Rugby', 'icon': Icons.sports_football},
      {'name': 'Running', 'icon': Icons.directions_run},
      {'name': 'Skiing', 'icon': Icons.downhill_skiing},
      {'name': 'Skating', 'icon': Icons.skateboarding},
      {'name': 'Swimming', 'icon': Icons.pool},
      {'name': 'Table Tennis', 'icon': Icons.sports_tennis},
      {'name': 'Tennis', 'icon': Icons.sports_tennis},
      {'name': 'Volleyball', 'icon': Icons.sports_volleyball},
      {'name': 'Yoga', 'icon': Icons.self_improvement},
      {'name': 'Other', 'icon': Icons.more_horiz},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Sports'),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index]['name'];
          final icon = sports[index]['icon'];
          return _buildSportCard(
            context,
            sport,
            icon,
          );
        },
      ),
    );
  }

  Widget _buildSportCard(
    BuildContext context,
    String sportName,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SportEventsPage(
              sportName: sportName,
              sportIcon: icon,
              events: [], // Initially empty, you might want to fetch events based on sport
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.green[400],
            ),
            const SizedBox(height: 8),
            Text(
              sportName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 