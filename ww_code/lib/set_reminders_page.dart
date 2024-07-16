import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:ww_code/aesthetics/textfield_style.dart';
import 'notif_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime scheduleTime = DateTime.now();

class NotifSystem extends StatefulWidget {
  const NotifSystem({super.key, required this.title});
  final String title;

  @override
  State<NotifSystem> createState() => NotifSystemState();
}

class NotifSystemState extends State<NotifSystem> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  // Function to show a Snackbar
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5), // Adjust duration as needed
      ),
    );
  }

  // Function to allow users to select trip from their trip planner page
  Future<void> selectTrip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Unauthenticated user');
      return;
    }

    final tripsSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Itineraries')
        .get();

    final trips = tripsSnapshot.docs;

    if (trips.isEmpty) {
      showSnackbar('No trips found in Trip Planner');
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Select a Trip',
              style: TextStyle(color: Colors.lightBlue),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (BuildContext context, int index) {
                    final trip = trips[index];
                    return ListTile(
                      title: Text(
                        trip['title'],
                        style: const TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        setState(() {
                          titleController.text = trip['title'];
                          bodyController.text =
                              '${trip['startDate']} - ${trip['endDate']}';
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.lightBlue),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/reminders.png',
                height: 200,
              ),
              const SizedBox(height: 10),
              const Text(
                'Set reminders for your upcoming trips!',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: titleController,
                      style: const TextStyle(color: Colors.black),
                      decoration: TextFieldConfig.buildInputDecoration(
                        hintText: 'Enter reminder title',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.description_sharp),
                    onPressed: selectTrip,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                cursorColor: Colors.black,
                controller: bodyController,
                style: const TextStyle(color: Colors.black),
                decoration: TextFieldConfig.buildInputDecoration(
                  hintText: 'Enter reminder details',
                ),
              ),
              const SizedBox(height: 10),
              const DatePickerTxt(),
              const SizedBox(height: 5),
              ElevatedButton(
                child: const Text('  Schedule Reminder  '),
                onPressed: () async {
                  await Permission.scheduleExactAlarm.request();
                  if (await Permission.scheduleExactAlarm.isGranted) {
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        showSnackbar('User not logged in.');
                        return;
                      }

                      // Save or update the reminder in Firestore
                      final reminderData = {
                        'title': titleController.text,
                        'description': bodyController.text,
                        'scheduleTime': scheduleTime,
                      };

                      final reminderDoc = FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user.uid)
                          .collection('Reminders')
                          .doc();

                      await reminderDoc.set(reminderData);

                      NotificationService().scheduleNotification(
                        title: titleController.text,
                        body: bodyController.text,
                        scheduleNotificationDateTime: scheduleTime,
                        context: context,
                      );

                      showSnackbar(
                          'Notification Scheduled Successfully for $scheduleTime');
                    } catch (e) {
                      debugPrint('Error scheduling notification: $e');
                      showSnackbar('Error scheduling notification: $e');
                    }
                  } else {
                    showSnackbar(
                        'Permission not granted to schedule notification');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DatePickerTxt extends StatefulWidget {
  const DatePickerTxt({super.key});

  @override
  State<DatePickerTxt> createState() => _DatePickerTxtState();
}

class _DatePickerTxtState extends State<DatePickerTxt> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onChanged: (date) => scheduleTime = date,
          onConfirm: (date) {},
        );
      },
      child: const Text('Select Date and Time'),
    );
  }
}
