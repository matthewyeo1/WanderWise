import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aesthetics/colour_gradient.dart';

class MapItineraryPage extends StatefulWidget {
  const MapItineraryPage({super.key});

  @override
  MapItineraryPageState createState() => MapItineraryPageState();
}

class MapItineraryPageState extends State<MapItineraryPage> {
  int _selectedIndex = 0;
  List<String> _itineraryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItineraryItems();
  }

  Future<void> _loadItineraryItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _itineraryItems = prefs.getStringList('itineraryItems') ?? [];
    });
  }

  Future<void> _saveItineraryItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('itineraryItems', _itineraryItems);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addItineraryItem() {
    setState(() {
      _itineraryItems.add('');
    });
    _saveItineraryItems();
  }

  void _removeItineraryItem(int index) {
    setState(() {
      _itineraryItems.removeAt(index);
    });
    _saveItineraryItems();
  }

  void _editItineraryItem(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItineraryPage(
          initialText: _itineraryItems[index],
          onSave: (newText) {
            setState(() {
              _itineraryItems[index] = newText;
            });
            _saveItineraryItems();
          },
        ),
      ),
    );
  }

  Widget _buildItineraryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _itineraryItems.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white.withOpacity(0.8),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              _itineraryItems[index],
              style: const TextStyle(color: Colors.black),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editItineraryItem(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItineraryItem(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Map/Itinerary'),
        foregroundColor: const Color(0xFF00A6DF),
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
        decoration: BoxDecoration(
          gradient: getAppGradient(),
        ),
        child: Center(
          child: _selectedIndex == 0
              ? const Text(
                  '<google maps>',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                )
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

class EditItineraryPage extends StatelessWidget {
  final String initialText;
  final ValueChanged<String> onSave;

  const EditItineraryPage({
    Key? key,
    required this.initialText,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: initialText);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13438B),
        title: const Text('Edit Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Enter detailed itinerary',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

