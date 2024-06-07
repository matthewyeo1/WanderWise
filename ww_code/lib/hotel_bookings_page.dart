import 'package:flutter/material.dart';

class HotelBookingsPage extends StatelessWidget {
  const HotelBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Existing hotel booking widgets
            // Add a button to create a new folder
            ElevatedButton(
              onPressed: () {
                _createNewFolder(context);
              },
              child: const Text('Create New Folder'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewFolder(BuildContext context) async {
    final TextEditingController folderNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              labelText: 'Folder Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveFolder(folderNameController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveFolder(String folderName) {
    // Save the folder to Firestore or handle it accordingly
  }
}
