import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:ww_code/select_favourite_locations.dart';
import 'localization/locales.dart';

class EditItineraryPage extends StatefulWidget {
  final Map<String, dynamic>? initialItem;
  final ValueChanged<Map<String, dynamic>> onSave;
  final String title;

  const EditItineraryPage({
    super.key,
    this.initialItem,
    required this.onSave,
    required this.title,
  });

  @override
  EditItineraryPageState createState() => EditItineraryPageState();
}

class EditItineraryPageState extends State<EditItineraryPage> {
  late TextEditingController titleController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController descriptionController;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.initialItem?['title'] ?? '');
    startDateController =
        TextEditingController(text: widget.initialItem?['startDate'] ?? '');
    endDateController =
        TextEditingController(text: widget.initialItem?['endDate'] ?? '');
    descriptionController =
        TextEditingController(text: widget.initialItem?['description'] ?? '');
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

  void _navigateToSelectFavouritesPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SelectFavouriteLocations(), ),
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTextColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final cursorColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final saveButtonTextColor = theme.brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF00A6DF);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => _navigateToSelectFavouritesPage(context),
              
            
            icon: const Icon(Icons.favorite),
            
          ),
          IconButton(
            onPressed: () {
              widget.onSave({
                'id': widget.initialItem?['id'] ?? DateTime.now().toString(),
                'title':
                    titleController.text.isEmpty ? '' : titleController.text,
                'description': descriptionController.text.isEmpty
                    ? ''
                    : descriptionController.text,
                'startDate': startDateController.text.isEmpty
                    ? ''
                    : startDateController.text,
                'endDate': endDateController.text.isEmpty
                    ? ''
                    : endDateController.text,
              });
              Navigator.pop(context);
            },
            icon: Icon(Icons.save, color: saveButtonTextColor),
            tooltip: 'Save',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              cursorColor: cursorColor,
              controller: titleController,
              style: TextStyle(color: inputTextColor),
              decoration: InputDecoration(
                labelText: LocaleData.title.getString(context),
                labelStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            TextField(
              cursorColor: cursorColor,
              controller: startDateController,
              style: TextStyle(color: inputTextColor),
              decoration: InputDecoration(
                labelText: LocaleData.startDate.getString(context),
                labelStyle: const TextStyle(color: Colors.grey),
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onTap: () => _selectDate(context, startDateController),
            ),
            TextField(
              cursorColor: cursorColor,
              controller: endDateController,
              style: TextStyle(color: inputTextColor),
              decoration: InputDecoration(
                labelText: LocaleData.endDate.getString(context),
                labelStyle: const TextStyle(color: Colors.grey),
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
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
                      cursorColor: cursorColor,
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: TextStyle(color: inputTextColor),
                      decoration: InputDecoration(
                        labelText: LocaleData.description.getString(context),
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
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
