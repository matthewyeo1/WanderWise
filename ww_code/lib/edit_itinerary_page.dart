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
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
        text: widget.initialItem?['itinerary.title'] ?? '');
    startDateController = TextEditingController(
        text: widget.initialItem?['itinerary.startDate'] ?? '');
    endDateController = TextEditingController(
        text: widget.initialItem?['itinerary.endDate'] ?? '');
    descriptionController = TextEditingController(
        text: widget.initialItem?['itinerary.description'] ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.blue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.lightBlue,
        title: const Text('Edit Itinerary'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSave({
                'itinerary.id': widget.initialItem?['itinerary.id'] ??
                    DateTime.now().toString(),
                'itinerary.title': titleController.text,
                'itinerary.description': descriptionController.text,
                'itinerary.startDate': startDateController.text,
                'itinerary.endDate': endDateController.text,
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.lightBlue,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              cursorColor: Colors.lightBlue,
              controller: titleController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            TextField(
              cursorColor: Colors.lightBlue,
              controller: startDateController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Start Date',
                labelStyle: TextStyle(color: Colors.grey),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onTap: () => _selectDate(context, startDateController),
            ),
            TextField(
              cursorColor: Colors.lightBlue,
              controller: endDateController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'End Date',
                labelStyle: TextStyle(color: Colors.grey),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onTap: () => _selectDate(context, endDateController),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Check for pasted content
                        if (value.contains('![Image]')) {
                          // Clear the text and insert the image at the cursor position
                          final newText = value.replaceAll('![Image]', '');
                          final textSelection = descriptionController.selection;
                          final newTextWithImage =
                              '${newText.substring(0, textSelection.start)}![Image]${newText.substring(textSelection.end)}';
                          descriptionController.value = TextEditingValue(
                            text: newTextWithImage,
                            selection: TextSelection.collapsed(
                                offset: textSelection.start + 8),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
