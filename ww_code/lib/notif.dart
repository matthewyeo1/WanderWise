// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'aesthetics/textfield_style.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';




// class notifSystem extends StatefulWidget{
//   const notifSystem ({super.key, required this.title});
//   final String title;
//   @override
//   State <notifSystem> createState() => notifSystemState();
 
// }






// class NotificationService{
//   final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();


//   Future <void> iniNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//     const AndroidInitializationSettings('defaultIcon');
//     // app icon to be shown when there is a notification
//     var initializationSettingsIOS =  DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       onDidReceiveLocalNotification: (int id, String? title,String? body, String? payload) async {}
//     );
//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//       await notificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse:
//         (NotificationResponse notificationResponse)async {});
//   }


//   notificationDetails(){
//     return const NotificationDetails(
//       android: AndroidNotificationDetails('channelId', 'channelName',
//         importance: Importance.max),
//       iOS: DarwinNotificationDetails(),
//     );
//   }


//   Future showNotification(
//     {int id = 0, String? title, String? body, String? payLoad}) async{
//       return notificationsPlugin.show(
//         id, title, body, await notificationDetails()
//       );
//     }
// }


// class notifSystemState extends State<notifSystem>{
 
//   @override
 
//   Widget build (BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text('Show notifications'),
//           onPressed: (){
//             NotificationService().showNotification(title:' Sample title', body: 'It works!');
//           },),
//       ),
//     );
//  }
// }


