import 'package:flutter/material.dart';
import 'package:ww_code/set_reminders_page.dart';
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

  final List<String> options = ['Personal Profile', 'General Settings', 'Set Reminders'];

  Widget _getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const ProfilePage();
      case 1:
        return const GeneralSettingsPage();
      case 2:
        return const NotifSystem(title: 'Set Reminders');
      default:
        return const ProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text(options[selectedIndex]),
      ),
      body: 
        
        Center(
          child: _getSelectedWidget(selectedIndex),
        ),
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
        ),
        child: BottomNavigationBar(
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
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: 'Reminders',
            ),
          ],
          currentIndex: selectedIndex,    
          onTap: _onItemTapped,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}