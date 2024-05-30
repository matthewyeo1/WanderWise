import 'package:flutter/material.dart';

class EditItineraryPage extends StatefulWidget {
  final Map<String, dynamic>? initialItem;
  final ValueChanged<Map<String, dynamic>> onSave;

  const EditItineraryPage({
    Key? key,
    this.initialItem,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditItineraryPageState createState() => _EditItineraryPageState();
}

class _EditItineraryPageState extends State<EditItineraryPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialItem?['title'] ?? '');
    descriptionController = TextEditingController(text: widget.initialItem?['description'] ?? '');
    startDateController = TextEditingController(text: widget.initialItem?['startDate'] ?? '');
    endDateController = TextEditingController(text: widget.initialItem?['endDate'] ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13438B),
        title: const Text('Edit Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave({
                'id': widget.initialItem?['id'] ?? DateTime.now().toString(),
                'title': titleController.text,
                'description': descriptionController.text,
                'startDate': startDateController.text,
                'endDate': endDateController.text,
              });
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
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              controller: startDateController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Start Date',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              controller: endDateController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'End Date',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

