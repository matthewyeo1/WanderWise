import 'package:flutter/material.dart';

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
  
   Widget _getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const Text(
          "Profile",
          style: TextStyle(fontSize: 20),
        );
      case 1:
        return const Text(
          "Change Password",
          style: TextStyle(fontSize: 20),
        );
      case 2:
        return const Text(
          "Change Display",
          style: TextStyle(fontSize: 20),
        );
      case 3:
        return const Text(
          "Offline Sync",
          style: TextStyle(fontSize: 20),
        );
      default:
        return const Text(
          "Profile",
          style: TextStyle(fontSize: 20),
        );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Profile'),
      ),
      body: Center(
        child: _getSelectedWidget(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.password),
            label: 'Change Password',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.display_settings),
            label: 'Change Display',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.offline_bolt),
            label: 'Offline Sync',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}
       
          
