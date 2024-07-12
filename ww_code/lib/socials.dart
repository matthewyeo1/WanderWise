// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'notif_service.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
// import 'package:awesome_notifications/awesome_notifications.dart';




// class notifSystem extends StatefulWidget {
//   const notifSystem({super.key, required this.title});
//   final String title;

//   @override
//   State<notifSystem> createState() => notifSystemState();
// }

// class notifSystemState extends State<notifSystem> {
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(child: ElevatedButton(
//         child:const Text("Shownotif"),
//         onPressed: () {
//           NotificationService().showNotification(title: 'Sample title', body:'It works');
//         },
//       )),
//     );
//   }
// }













// class sendNotif extends StatefulWidget{
//   const sendNotif ({Key?key}) :super(key: key);

//   @override
//   State<sendNotif>createState() => _sendNotifState();
// }


// class _sendNotifState extends State<sendNotif> {
//   final TextEditingController title = TextEditingController();
//   final TextEditingController desc = TextEditingController();


//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


//   @override
//   void initState(){
//     super.initState();
//     const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("logo1");
//     // ignore: non_constant_identifier_names
//     final IOSinitializationSettings =  DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       onDidReceiveLocalNotification: (int id, String? title,String? body, String? payload) async {}
//     );
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: androidInitializationSettings,
//       iOS: IOSinitializationSettings,
//       macOS: null,
//       linux: null,

//     )
//   }
// }













// class NotificationService{
//   static Future<void>initializeNotifications() async{
//     await AwesomeNotifications().initialize(
//       null,
//       [
//         NotificationChannel(
//           channelGroupKey: 'high_importance_channel',
//           channelKey: 'high_importance_channel',
//           channelName: 'Basic notifications',
//           channelDescription: 'Notification channel for basic tests',
//           defaultColor: const Colors.blue,
//           ledColor: Colors.white,
//           importance: NotificationImportance.Max,
//           channelShowBadge: true,
//           onlyAlertOnce: true,
//           playSound: true,
//           criticalAlerts: true,
//         )
//       ],
//       channelGroups: [
//         NotificationChannelGroup(
//           channelGroupKey: 'high_importance_channel_group',
//           channelGroupName: 'Group 1',
//         )
//       ],
//       debug: true,
//     );
//     await AwesomeNotifications().isNotificationAllowed().then(
//       (isAllowed) async{
//         if (!isAllowed){
//           await AwesomeNotifications().requestPermissionToSendNotifications();
//         }
//       },
//     );

//     await AwesomeNotifications.setListeners(
//       onActionReceivedMethod: onActionReceivedMethod,
//       onNotificationCreatedMethod: onNotificationCreatedMethod,
//       onNotificationDisplayedMethod: onNotificationDisplayedMethod,
//       onDismissActionReceivedMethod: onDismissActionReceivedMethod,
//     );
//   }
//   static Future<void> onNotificationCreatedMethod(
//     ReceivedNotification rceivedNotification) async {
//       debugPrint('onnotifcreated method');
//     }
//   static Future<void> onNotificationDisplayedMethod(
//     ReceivedNotification rceivedNotification) async {
//       debugPrint('onnotifcreated method');
//     }
//   static Future<void> onDimissActionReceivedMethod(
//     ReceivedNotification rceivedNotification) async {
//       debugPrint('onnotifcreated method');
//     }
//   static Future<void> onActionReceivedMethod(
//     ReceivedNotification rceivedNotification) async {
//       debugPrint('onnotifcreated method');
//       final payload = receivedAction.payload ?? {};
//       if (payload["navigate"] == "true"){

//       }
//     }

//   static Future<void> showNotification({
//     required final String title,
//     required final String body,
//     final String? summary,
//     final Map<String, String>? payload,
//     final ActionType actionType = ActionType.Default,
//     final NotificationLayout notificationLayout = NotificationLayout.Default,
//     final NotificationCategory? category,
//     final String? bigPicture,
//     final List<NotificationActionButton>? actionButtons,
//     final bool scheduled = false,
//     final int? interval,
//   }) async {
//     assert(!scheduled || (scheduled&& interval != null));

//     await AwesomeNotifications.createNotification(
//       content:  NotificationContent(
//         id: -1,
//         channelKey: 'high_importance_channel',
//         title: title,
//         body: body,
//         actionType: actionType,
//         notificationLayout: notificationLayout,
//         summary: summary,
//         category: category,
//         payload: payload,
//         bigPicture: bigPicture,
//       ),
//       actionButtons: actionButtons,
//       schedule: scheduled?
//       NotificationInterval(interval: ,
//       timeZone: await AwesomeNotifications.getlocalTimeZoneIdentifier(),
//       preciseAlarm: true,
//     )

//   : null,
//     );
//   }
// }








 
























// class PushNotificationService
// {
//   static Future<String> getAccessToken() async
//   {
//     final serviceAccountJson = 
//     {

//       "type": "service_account",
//       "project_id": "flutter-project-12d4b",
//       "private_key_id": "5085f5f8baf035f9dab014d3aed51a012842eee9",
//       "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDMBMOx9Q2jV7Lg\n2RmXYk6BnTevyTfrn+im++PF3INXTFOByR+TnevUJbBwitaEf53/LNZ/E+S7kEBP\nosN9l+pVILxVSiGYWEdRtmfBxJzGxg6G1nqcFpWDVYIBVt2KwdZ416EfVjAGXVYs\nn0nFg8aYxK4dtFu5NmrNTx/fkLgoylpzrRybnhPq6RcWHBlCEydoTSXmanBX2Hq4\n31ocn7xcJOD4Qy0kGY3Pv5O/eR6S2ConJXa2VjrSl1tCWBIkrZNr939NaoBZxX7/\naVufFonlX+CLvzov1+NvX8w5PYFgY7zbp3ciky7mhbIm/tjKWdBtitn87nTcgP1X\nqHUf0LvJAgMBAAECggEABrOJXLO4lPWb0eLlAkyfrjDkfrOp+zqva6djyJYBAmxm\nucv0wOaJCS42aMacBpIiixqFQ9Cld2Zk67i5mcspo/jaoXqOi/B/tza58GrC3jdB\n4Y/zSw6QLquFBQI+GKwGnXAybKhqFMDFbzB0PeFMNAG8g7aZj1sy5YzZy9V3FxqE\nvpJpFoXa6AoDsVi8kLc2lSL+8+obPYIroPfPoswMidGzoio9Jtjsqe+Wdvc19HdP\nOLDsZ6p5zPoxDpzXciPTzYTrT8YFi7h3mQaojOOvDkEXZsC33D2NWuzTQ+NP8eKv\nuhuEhZzZoi8oT3JLjFLSgbpfVKol8UEFve0HBFPcYQKBgQDz0NpFYkpKkeEyfPqz\nnCoU3/hAfFlrpN2waQm5Xvcu6TAS6qDw3FsLEwyLS5VDOXthwp0sINaNJ3tdmocB\nsn5nzEJ8ZfWIpy9IYz4rj8L+QF80xRsQuluDmIPm+SLv/NWJGGVCd0hz8fW9BBhb\nyjQFl3zVmTmxSm85+qHyLtDchQKBgQDWNsi7rnj1SEWvZaAtvZALHiT/3YhwA0hZ\n1aYlTnbDdJe21vHWCVcvjDp6PDGaDz4PCE+N0uqdAUoMn5VbudylKSy096Fd7BB3\nmhOxBn+NokogauX40xuepxwrkUx0tIGQMJkulqyS9CaxMxS/632Jme8hSH7Hw6oG\nFb04+BwXdQKBgGE7sVBqWmZStxSDcxed98pLZ52P+blMDn0D5rTegoVayalBmN11\ng3lvJ1mF0wj0K5hZHIU0s1unmzNBJQYwQOj0NK+XmcvdoKWlrm2A76ql0VIiKSEK\nsORSNoguYxiCJEaATCGtoF9c5ztyHqS8hvKT71zftnpVzPW6VktXEERhAoGBAMn6\nyfa9IewVAy/IoOnADWuONtDSr2z+i1+5JXmTrEPLUanirhBkqkJ49EKBMzvSF2/R\nJEHTl8gGiS2x4wCkFTndwvu3af3HMhezvdFzER4Y4dADO2gMlcRYSSWDURXRhUDR\nsf3NsFa3wyvdwDjd8HaoIGO/mVr+UPh/0vU+bC5pAoGAZmUlYOGX6QM35Me5p+zQ\n1s541WXESwPhlY9bQvkoIwidtkthhry63+9iWeeeDkYjQkKVCLzPJBBS3imZ1gWv\ndn0SYfDPOiVfHaTcyS2WvD2EN/s9Mh+COo5rGXrNauZXquAFW5GVxNHKuEo2pMls\n1lrIyFC0ZyMXzrFKdsnN5lE=\n-----END PRIVATE KEY-----\n",
//       "client_email": "wanderwise123@flutter-project-12d4b.iam.gserviceaccount.com",
//       "client_id": "101474568904645312600",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/wanderwise123%40flutter-project-12d4b.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com"


//     };

//     List <String> scopes = 
//     [
//       "https://www.googleapis.com/auth/userinfo.email",
//       "https://www.googleapis.com/auth/firebase.database",
//       "https://www.googleapis.com/auth/firebase.messaging"
//     ];
//     http.Client client = await auth.clientViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//       scopes,
//     );

//     //get the access token
//     auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//       scopes,
//       client
//     );

//     client.close();

//     return credentials.accessToken.data;
//   }

//   static sendNotificationToSelectedDriver(String deviceToken, BuildContext context, String tripID) async
//   {
    
//     final String serverKey = await getAccessToken();
//     String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/flutter-project-12d4b/messages:send';

//     final Map<String, dynamic> message = 
//     {
//       'message':
//       {
//         'token': deviceToken,
//         'notification':
//         {
//           'title': ''
//           'body': ''
//         }
//       }
//     }
//   }
// }








































// class WendyAI extends StatelessWidget {
//   const WendyAI({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Socials"),
//       ),
//       body : const Text('To be added later'),

//     );
//   }
// }



DateTime scheduleTime = DateTime.now();

class notifSystem extends StatefulWidget {
  const notifSystem({super.key, required this.title});
  final String title;

  @override
  State<notifSystem> createState() => notifSystemState();
}

class notifSystemState extends State<notifSystem> {
  final TextEditingController titl = TextEditingController();
  final TextEditingController body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Socials"),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            DatePickerTxt(),
            ScheduleBtn(),
            SchedBtn()

          
          ],
        ),
      ),
    );
  }
}

class DatePickerTxt extends StatefulWidget {
  const DatePickerTxt({Key? key}) : super(key: key);

  @override
  State<DatePickerTxt> createState() => _DatePickerTxtState();
}

class _DatePickerTxtState extends State<DatePickerTxt> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onChanged: (date) => 
            scheduleTime = date,
          onConfirm: (date) {},
        );
      },
      child: const Text(
        'Select Date and Time',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}

class ScheduleBtn extends StatelessWidget {
  const ScheduleBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Schedule notifications'),
      onPressed: () async {
        
        if (await Permission.scheduleExactAlarm.request().isGranted){
        debugPrint('Notifications Scheduled for $scheduleTime');
        NotificationService().scheduleNotification(
          title: 'Scheduled Notification',
          body: '$scheduleTime',
          scheduleNotificationDateTime: scheduleTime
          // tz.TZDateTime.from(scheduleTime, tz.local),
        );}
      },
    );
  }
}

class SchedBtn extends StatelessWidget {
  const SchedBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Sched notifications'),
      onPressed: () async {
   NotificationService().showNotification(title: '1', body: '3');
      },
    );
  }
}