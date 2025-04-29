import 'package:flutter/material.dart';
import 'sport_events_page.dart';
import 'more_sports_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedLocation = 'Loading location...';
  List<String> _eventSuggestions = [];
  List<String> _locationSuggestions = [];
  Position? _currentPosition;
  bool _isLocationEnabled = false;

  // Mock data for events
  final List<Map<String, dynamic>> _allEvents = [
    {
      'name': 'Basketball at City Park',
      'location': 'City Park Courts, San Francisco',
      'sport': 'Basketball',
      'date': 'Today, 6:00 PM',
      'participants': 8,
    },
    {
      'name': 'Football Match at Downtown Field',
      'location': 'Downtown Field, San Francisco',
      'sport': 'Football',
      'date': 'Tomorrow, 4:00 PM',
      'participants': 16,
    },
    {
      'name': 'Tennis Doubles at Tennis Center',
      'location': 'Tennis Center, San Jose',
      'sport': 'Tennis',
      'date': 'Saturday, 10:00 AM',
      'participants': 4,
    },
    {
      'name': 'Volleyball Practice at Beach Courts',
      'location': 'Beach Courts, Oakland',
      'sport': 'Volleyball',
      'date': 'Sunday, 2:00 PM',
      'participants': 12,
    },
  ];

  // Mock data for location suggestions
  final Map<String, List<String>> _locationSuggestionsByCity = {
    'San Francisco': [
      'San Francisco, CA',
      'Mission District, SF',
      'Financial District, SF',
      'North Beach, SF',
      'Marina District, SF',
    ],
    'San Jose': [
      'San Jose, CA',
      'Downtown San Jose',
      'Santana Row',
      'Willow Glen',
      'Almaden Valley',
    ],
    'Oakland': [
      'Oakland, CA',
      'Downtown Oakland',
      'Rockridge',
      'Temescal',
      'Lake Merritt',
    ],
  };

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLocationEnabled = false;
        _selectedLocation = 'Location services disabled';
      });
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLocationEnabled = false;
          _selectedLocation = 'Location permission denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLocationEnabled = false;
        _selectedLocation = 'Location permission permanently denied';
      });
      return;
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLocationEnabled = true;
        _selectedLocation = 'Current Location';
        _locationController.text = _selectedLocation;
      });
    } catch (e) {
      setState(() {
        _isLocationEnabled = false;
        _selectedLocation = 'Unable to get location';
      });
    }
  }

  void _updateEventSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _eventSuggestions = [];
        return;
      }
      
      // Search in event names, locations, and sports
      _eventSuggestions = _allEvents
          .where((event) => 
            event['name'].toLowerCase().contains(query.toLowerCase()) ||
            event['location'].toLowerCase().contains(query.toLowerCase()) ||
            event['sport'].toLowerCase().contains(query.toLowerCase())
          )
          .map((event) => event['name'] as String)
          .toList();
    });
  }

  void _updateLocationSuggestions(String query) {
    setState(() {
      if (_isLocationEnabled && _currentPosition != null) {
        String currentCity = _getCurrentCity();
        List<String> nearbyLocations = _locationSuggestionsByCity[currentCity] ?? [];
        _locationSuggestions = [
          ...nearbyLocations.where((location) => 
            location.toLowerCase().contains(query.toLowerCase())
          ),
          ..._locationSuggestionsByCity.values
              .expand((locations) => locations)
              .where((location) => 
                location.toLowerCase().contains(query.toLowerCase()) &&
                !nearbyLocations.contains(location)
              ),
        ];
      } else {
        _locationSuggestions = _locationSuggestionsByCity.values
            .expand((locations) => locations)
            .where((location) => 
              location.toLowerCase().contains(query.toLowerCase())
            )
            .toList();
      }
    });
  }

  void _selectLocation(String location) {
    setState(() {
      _selectedLocation = location;
      _locationController.text = _selectedLocation;
      _locationSuggestions = [];
    });
  }

  void _performSearch() {
    final String searchQuery = _searchController.text.toLowerCase();
    final String locationQuery = _locationController.text.toLowerCase();
    
    List<Map<String, dynamic>> searchResults = _allEvents.where((event) {
      bool matchesSearch = searchQuery.isEmpty || 
          event['name'].toLowerCase().contains(searchQuery) ||
          event['sport'].toLowerCase().contains(searchQuery);
      bool matchesLocation = locationQuery.isEmpty ||
          event['location'].toLowerCase().contains(locationQuery);
      return matchesSearch && matchesLocation;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          results: searchResults,
          searchQuery: searchQuery,
          locationQuery: locationQuery,
        ),
      ),
    );
  }

  String _getCurrentCity() {
    // In a real app, you would use reverse geocoding here
    // For now, we'll use a simple mock based on coordinates
    if (_currentPosition == null) return 'San Francisco';
    
    // Mock logic to determine city based on coordinates
    if (_currentPosition!.latitude > 37.7 && _currentPosition!.latitude < 37.8) {
      return 'San Francisco';
    } else if (_currentPosition!.latitude > 37.3 && _currentPosition!.latitude < 37.4) {
      return 'San Jose';
    } else {
      return 'Oakland';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _eventSuggestions = [];
            _locationSuggestions = [];
          });
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Search with suggestions
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _locationController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter location...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: Icon(
                              _isLocationEnabled ? Icons.my_location : Icons.location_off,
                              color: _isLocationEnabled ? Colors.green[400] : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: _updateLocationSuggestions,
                        ),
                        if (_locationSuggestions.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _locationSuggestions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    _locationSuggestions[index],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    _selectLocation(_locationSuggestions[index]);
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Event Search with suggestions
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search events or sports...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: _performSearch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[400],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Search'),
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: _updateEventSuggestions,
                        ),
                        if (_eventSuggestions.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _eventSuggestions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    _eventSuggestions[index],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    final event = _allEvents.firstWhere(
                                      (e) => e['name'] == _eventSuggestions[index],
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailsPage(event: event),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Choose a Sport Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choose a Sport',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MoreSportsPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'More Sports',
                              style: TextStyle(
                                color: Colors.green[400],
                                fontSize: 16,
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.green[400]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sport Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildSportCard(context, 'Basketball', Icons.sports_basketball),
                      _buildSportCard(context, 'Football', Icons.sports_soccer),
                      _buildSportCard(context, 'Tennis', Icons.sports_tennis),
                      _buildSportCard(context, 'Volleyball', Icons.sports_volleyball),
                      _buildSportCard(context, 'Running', Icons.directions_run),
                      _buildSportCard(context, 'Ice Hockey', Icons.sports_hockey),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Upcoming Events Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Events',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: Colors.green[400],
                                fontSize: 16,
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.green[400]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Event Card
                  _buildEventCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSportCard(BuildContext context, String sport, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Filter events based on selected location
        List<Map<String, dynamic>> filteredEvents = _allEvents.where((event) {
          if (_selectedLocation == 'Current Location' && _currentPosition != null) {
            String currentCity = _getCurrentCity();
            return event['sport'] == sport && 
                   event['location'].toLowerCase().contains(currentCity.toLowerCase());
          } else if (_selectedLocation != 'Loading location...' && 
                    _selectedLocation != 'Location services disabled' &&
                    _selectedLocation != 'Location permission denied' &&
                    _selectedLocation != 'Location permission permanently denied' &&
                    _selectedLocation != 'Unable to get location') {
            return event['sport'] == sport && 
                   event['location'].toLowerCase().contains(_selectedLocation.toLowerCase());
          }
          return event['sport'] == sport;
        }).toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SportEventsPage(
              sportName: sport,
              sportIcon: icon,
              events: filteredEvents,
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
              color: Colors.green[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              sport,
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

  Widget _buildEventCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[800],
              child: const Center(
                child: Icon(
                  Icons.sports_basketball,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basketball at City Park',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Today, 6:00 PM',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'City Park Courts',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final String searchQuery;
  final String locationQuery;

  const SearchResultsPage({
    super.key,
    required this.results,
    required this.searchQuery,
    required this.locationQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: results.isEmpty
          ? const Center(child: Text('No results found'))
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final event = results[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text(event['location']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsPage(event: event),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['name']),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['name'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Location: ${event['location']}'),
            Text('Sport: ${event['sport']}'),
            Text('Date: ${event['date']}'),
            Text('Participants: ${event['participants']}'),
          ],
        ),
      ),
    );
  }
} 