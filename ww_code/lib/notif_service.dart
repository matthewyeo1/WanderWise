


import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';


class NotificationService{
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();


  Future <void> iniNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('logo1');
    // app icon to be shown when there is a notification
    var initializationSettingsIOS =  DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title,String? body, String? payload) async {}
    );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse)async {});
  }


  


  notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName',
       icon: 'logo1',
        importance: Importance.high),
      iOS: DarwinNotificationDetails(),
    );
  }


  Future showNotification(
    {int id = 0, String? title, String? body, String? payLoad}) async{
      return notificationsPlugin.show(
        id, title, body, await notificationDetails()
      );
    }


    Future scheduleNotification( 
  {
    int id = 1, 
    String? title,
    String? body,
    String? payLoad,
    required DateTime scheduleNotificationDateTime
  }) async {
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduleNotificationDateTime,
        tz.local,
      ),
      await notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
      UILocalNotificationDateInterpretation.absoluteTime
    );
  }
}


// class NotificationService{
//   final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();


//   Future <void> iniNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//     const AndroidInitializationSettings('logo1');
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
//        icon: 'logo1',
//         importance: Importance.max),
//       iOS: DarwinNotificationDetails(),
//     );
//   }

//     Future showNotification(
//     {int id = 0, String? title, String? body, String? payLoad}) async{
//       return notificationsPlugin.show(
//         id, title, body, await notificationDetails()
//       );
//     }
// }