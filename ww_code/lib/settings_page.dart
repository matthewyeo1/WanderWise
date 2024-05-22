import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  //add stuff
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal, 
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Profile'),
              ),
            ),
            const SizedBox(height: 20),
             SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  //add stuff
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal, 
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Change Password'),
              ),
            ),
            const SizedBox(height: 20),
             SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  //add stuff
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal, 
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Change Display'),
              ),
            ),
            const SizedBox(height: 20),
             SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  //add stuff
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal, 
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Offline Sync'),
              ),
            ),
          ]
        ),
      ),
    );
  }
}
        
          
