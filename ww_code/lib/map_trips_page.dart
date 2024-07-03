import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_itinerary_page.dart';
import 'map_view.dart';
import 'storage/itinerary_service.dart';
import 'auth/auth_service.dart';
import 'ai_itinerary_page.dart';

class MapItineraryPage extends StatefulWidget {
  const MapItineraryPage({super.key});

  @override
  MapItineraryPageState createState() => MapItineraryPageState();
}

class MapItineraryPageState extends State<MapItineraryPage> {
  final ItineraryService _itineraryService = ItineraryService();
  final AuthServiceItinerary _authService = AuthServiceItinerary();

  int _selectedIndex = 0;
  List<Map<String, dynamic>> _itineraryItems = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    User? user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await _loadItineraryItems();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadItineraryItems() async {
    List<Map<String, dynamic>> items = await _itineraryService.loadItineraryItems(userId);
    setState(() {
      _itineraryItems = items;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addItineraryItem() async {
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItineraryPage(
          title: 'Add New Trip',
          onSave: (newItem) async {
            await _itineraryService.saveItinerary(userId, newItem);
            setState(() {
              _itineraryItems.add(newItem);
            });
          
          },
        ),
      ),
    );
  }

  Future<void> _removeItineraryItem(int index) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      String docId = _itineraryItems[index]['id'];
      await _itineraryService.deleteItinerary(userId, docId);
      setState(() {
        _itineraryItems.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete Successful!')),
      );
    }
  }

  Future<void> _editItineraryItem(int index) async {
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItineraryPage(
          title: 'View/Edit Trip',
          initialItem: _itineraryItems[index],
          onSave: (updatedItem) async {
            await _itineraryService.updateItinerary(userId, updatedItem);
            setState(() {
              _itineraryItems[index]['title'] = updatedItem['title'] ?? '';
              _itineraryItems[index]['startDate'] = updatedItem['startDate'] ?? '';
              _itineraryItems[index]['endDate'] = updatedItem['endDate'] ?? '';
              _itineraryItems[index]['description'] = updatedItem['description'] ?? '';
            });
          },
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Trip', style: TextStyle(color: Colors.black)),
          content: const Text('Delete this Trip?', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Widget _buildItineraryList() {
    if (_itineraryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/itinerary2.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 10),
            const Text(
              'Create trip plans with friends!',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _itineraryItems.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white.withOpacity(0.8),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                _itineraryItems[index]['title'],
                style: const TextStyle(color: Colors.black),
              ),
              subtitle: Text(
                'Start Date: ${_itineraryItems[index]['startDate']}\nEnd Date: ${_itineraryItems[index]['endDate']}',
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.black45),
                    onPressed: () => _editItineraryItem(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black45),
                    onPressed: () => _removeItineraryItem(index),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _navigateToAIItineraryPage() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const GeminiChatPage(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Map' : 'My Trips'),
        actions: _selectedIndex == 1
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItineraryItem,
                ),
                IconButton(
                icon: Image.asset(
                  'images/gemini_logo.png',
                  height: 24.0,
                  width: 24.0,
                ),
                onPressed: _navigateToAIItineraryPage,
                ),
              ]
            : null,
      ),
      body: Center(
        child: _selectedIndex == 0
            ? const GoogleMapWidget()
            : _buildItineraryList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Trips',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

