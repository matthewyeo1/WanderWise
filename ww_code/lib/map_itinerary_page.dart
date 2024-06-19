import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_itinerary_page.dart';
import 'map_view.dart';

class MapItineraryPage extends StatefulWidget {
  const MapItineraryPage({super.key});

  @override
  MapItineraryPageState createState() => MapItineraryPageState();
}

class MapItineraryPageState extends State<MapItineraryPage> {
  final CollectionReference _itineraryCollection =
      FirebaseFirestore.instance.collection('Users');
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _itineraryItems = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadItineraryItems();
  }

  Future<void> _initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
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
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Itineraries')
          .get();

      setState(() {
        _itineraryItems = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['itinerary.id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error loading itinerary items: $e');
    }
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
          onSave: (newItem) async {
            await _saveItineraryToFirestore(newItem);
            setState(() {
              _itineraryItems.add(newItem);
            });
          },
        ),
      ),
    );
  }

  Future<void> _saveItineraryToFirestore(Map<String, dynamic> itinerary) async {
    try {
      DocumentReference docRef = await _itineraryCollection
          .doc(userId)
          .collection('Itineraries')
          .add(itinerary);
      itinerary['itinerary.id'] = docRef.id;
    } catch (e) {
      print('Error saving itinerary to Firestore: $e');
    }
  }

  Future<void> _removeItineraryItem(int index) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      String docId = _itineraryItems[index]['itinerary.id'];
      try {
        await _itineraryCollection
            .doc(userId)
            .collection('Itineraries')
            .doc(docId)
            .delete();

        setState(() {
          _itineraryItems.removeAt(index);
        });
        print('Deleted');
      } catch (e) {
        print('Error deleting itinerary item: $e');
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Itinerary'),
          content: const Text('Delete this itinerary?'),
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

  Future<void> _editItineraryItem(int index) async {
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItineraryPage(
          initialItem: _itineraryItems[index],
          onSave: (updatedItem) async {
            await _updateItineraryInFirestore(updatedItem);
            setState(() {
              _itineraryItems[index] = updatedItem;
            });
          },
        ),
      ),
    );
  }

  Future<void> _updateItineraryInFirestore(
      Map<String, dynamic> itinerary) async {
    String docId = itinerary['itinerary.id'];
    try {
      await _itineraryCollection
          .doc(userId)
          .collection('Itineraries')
          .doc(docId)
          .update(itinerary);
    } catch (e) {
      print('Error updating itinerary in Firestore: $e');
    }
  }

  Widget _buildItineraryList() {
    if (_itineraryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/itinerary.jpg',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 10),
            const Text(
              'Create itineraries with friends',
              style: TextStyle(
                fontSize: 18, 
                color: Colors.black45, 
              ),
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
                _itineraryItems[index]['itinerary.title'],
                style: const TextStyle(color: Colors.black),
              ),
              subtitle: Text(
                'Start Date: ${_itineraryItems[index]['itinerary.startDate']}\nEnd Date: ${_itineraryItems[index]['itinerary.endDate']}',
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF00A6DF)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _selectedIndex == 0 ? 'Map' : 'Itinerary',
          style: const TextStyle(color: Color(0xFF00A6DF)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF00A6DF),
        ),
        actions: _selectedIndex == 1
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItineraryItem,
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: _selectedIndex == 0
              ? const GoogleMapWidget()
              : _buildItineraryList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Itinerary',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00A6DF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0.0,
        onTap: _onItemTapped,
      ),
    );
  }
}
