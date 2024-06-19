import 'package:flutter/material.dart';
import 'package:ww_code/aesthetics/colour_gradient.dart';
import 'profile_page.dart';
import 'general.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<String> options = ['Profile', 'General'];

  Widget _getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const ProfilePage();
      case 1:
        return const GeneralSettingsPage();         
      default:
        return const ProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF00A6DF),
        title: Text(options[selectedIndex]),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: getAppGradient(),
        ),
        child: Center(
          child: _getSelectedWidget(selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'General',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF00A6DF),
        backgroundColor: Colors.white,
        elevation: 0.0,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontSize: 12), 
        unselectedLabelStyle: const TextStyle(fontSize: 10), 
      ),
    );
  }
}
