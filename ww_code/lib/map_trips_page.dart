import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'edit_itinerary_page.dart';
import 'map_view.dart';
import 'storage/itinerary_service.dart';
import 'user/auth_service.dart';
import 'ai_itinerary_page.dart';
import 'aesthetics/themes.dart';
import 'package:ww_code/sharing_page.dart';
import 'package:ww_code/map_info_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'localization/locales.dart';


class MapItineraryPage extends StatefulWidget {
  const MapItineraryPage({super.key});

  @override
  MapItineraryPageState createState() => MapItineraryPageState();
}

// Page to hold user's trip plans and map
class MapItineraryPageState extends State<MapItineraryPage> {
  final ItineraryService _itineraryService = ItineraryService();
  final AuthServiceItinerary _authService = AuthServiceItinerary();

  int _selectedIndex = 0;
  List<Map<String, dynamic>> _itineraryItems = [];
  late String userId;
  bool savedItinerary = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  // Flag to handle navigation when trip plan made by Gemini is saved
  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  final shouldRefresh = ModalRoute.of(context)?.settings.arguments as bool?;
  if (shouldRefresh == true) {
    print('Refreshing itinerary items...');
    _loadItineraryItems();
  }
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
  try {
    print('Loading itinerary items for user: $userId');
    List<Map<String, dynamic>> items =
        await _itineraryService.loadItineraryItems(userId);

    // Handle null values in 'order' field
    items.sort((a, b) {
      final aOrder = a['order'] ?? double.maxFinite; // Place items with null 'order' at the end
      final bOrder = b['order'] ?? double.maxFinite;
      return aOrder.compareTo(bOrder);
    });

    setState(() {
      _itineraryItems = items;
      isLoading = false;
    });
    print('Itinerary items loaded: $_itineraryItems');
  } catch (e) {
    print('Error loading itinerary items: $e');
    setState(() {
      isLoading = false;
    });
  }
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addItineraryItem() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItineraryPage(
          title: LocaleData.addTrip.getString(context),
          onSave: (newItem) async {
            await _itineraryService.saveItinerary(userId, newItem);
            setState(() {
              _itineraryItems.add(newItem);
            });
          },
        ),
      ),
    );
    if (result != null) {
      await _loadItineraryItems();
    }
  }

  Future<void> _removeItineraryItem(int index) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      String docId = _itineraryItems[index]['id'];
      await _itineraryService.deleteItinerary(userId, docId);
      setState(() {
        _itineraryItems.removeAt(index);
      });
      print('Successfully deleted trip');
      
    }
  }

  void _navigateToInviteToCollabPage(String itineraryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ShareWithUsersPage(userId: userId, itineraryId: itineraryId)),
    );
  }

  Future<void> _editItineraryItem(int index) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItineraryPage(
          title: LocaleData.viewEditTrip.getString(context),
          initialItem: _itineraryItems[index],
          onSave: (updatedItem) async {
            await _itineraryService.updateItinerary(userId, updatedItem);
            setState(() {
              _itineraryItems[index]['title'] = updatedItem['title'] ?? '';
              _itineraryItems[index]['startDate'] =
                  updatedItem['startDate'] ?? '';
              _itineraryItems[index]['endDate'] = updatedItem['endDate'] ?? '';
              _itineraryItems[index]['description'] =
                  updatedItem['description'] ?? '';
            });
          },
        ),
      ),
    );
    if (result != null) {
      await _loadItineraryItems();
    }
  }

  Future<bool> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title:
              Text(LocaleData.deleteTrip.getString(context), style: TextStyle(color: Colors.black)),
          content: Text(LocaleData.deleteThisTrip.getString(context),
              style: const TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: Text(LocaleData.no.getString(context)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: Text(LocaleData.yes.getString(context)),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _updateItineraryOrderInFirestore() async {
  for (int index = 0; index < _itineraryItems.length; index++) {
    var itineraryItem = _itineraryItems[index];
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Itineraries')
        .doc(itineraryItem['id'])
        .update({'order': index});
  }
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
          Text(
            LocaleData.bodyText1.getString(context),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  } else {
    return ReorderableListView (
      padding: const EdgeInsets.all(16),
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _itineraryItems.removeAt(oldIndex);
          _itineraryItems.insert(newIndex, item);
        });

        _updateItineraryOrderInFirestore();
      },
      children: [
        for (int index = 0; index < _itineraryItems.length; index++)
          Card(
            key: ValueKey(_itineraryItems[index]['id']),
            color: Colors.white.withOpacity(0.8),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                _itineraryItems[index]['title'],
                style: const TextStyle(color: Colors.black),
              ),
              
              subtitle: Text(
                context.formatString(LocaleData.datesTrip, [_itineraryItems[index]['startDate'], _itineraryItems[index]['endDate']]),
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.black45),
                    onPressed: () => _navigateToInviteToCollabPage(
                        _itineraryItems[index]['id']),
                  ),
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
          ),
      ],
    );
  }
}


  // Function to load user's itineraries when navigating from page to page
  Future<void> _navigateToAIItineraryPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GeminiChatPage(),
      ),
    );
    if (result == true) {
      await _loadItineraryItems();
    }
  }

  // Function to display help page
  Future<void> _navigateToMapInfoPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapInfoPage(),
      ),
    );
   
  }

  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? LocaleData.trips.getString(context) : LocaleData.mapAppBar.getString(context)),
        actions: _selectedIndex == 0
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
            : [
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: _navigateToMapInfoPage,
                ),
              ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context)
                        .customColors
                        .circularProgressIndicatorLight
                    : Theme.of(context)
                        .customColors
                        .circularProgressIndicatorDark,
              ),
            ))
          : Center(
              child: _selectedIndex == 0
                  ? _buildItineraryList()
                  : const MapScreen(),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: LocaleData.trips.getString(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: LocaleData.mapAppBar.getString(context),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}