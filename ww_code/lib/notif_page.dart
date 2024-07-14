import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:ww_code/aesthetics/textfield_style.dart';
import 'notif_service.dart';
import 'package:permission_handler/permission_handler.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              cursorColor: Colors.black,
              controller: titleController,
              style: const TextStyle(color: Colors.black),
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Enter reminder title',         
              ),
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
            DatePickerTxt(),
            ElevatedButton(
              child: const Text('  Schedule reminder  '),
               onPressed: () async {
                  Permission.scheduleExactAlarm.request();
                  if (await Permission.scheduleExactAlarm.request().isGranted){
                    debugPrint('Notifications Scheduled for $scheduleTime');
                    NotificationService().scheduleNotification(
                      title: titleController.text,
                      body: bodyController.text,
                      scheduleNotificationDateTime: scheduleTime
                    );
                    }
                },
              ),
            // ScheduleBtn()
          ],
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
          onChanged: (date) => 
            scheduleTime = date,
          onConfirm: (date) {},
        );
      },
      // child: const Text(
      //   'Select Date and Time',
      //   style: TextStyle(color: Colors.blue),
      // ),
      child: const Text(
        'Select Date and Time',
        // style: TextStyle(color: Colors.blue),
      ),
    );
  }
}

// class ScheduleBtn extends StatelessWidget {
//   const ScheduleBtn({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       child: const Text('Schedule notifications'),
//       onPressed: () async {
//         Permission.scheduleExactAlarm.request();
//         if (await Permission.scheduleExactAlarm.request().isGranted){
//         debugPrint('Notifications Scheduled for $scheduleTime');
//         NotificationService().scheduleNotification(
//           title: 'Scheduled Notification',
//           body: '$scheduleTime',
//           scheduleNotificationDateTime: scheduleTime
//         );}
//       },
//     );
//   }
// }