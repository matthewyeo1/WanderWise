import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> iniNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('ww_logo');
    // app icon to be shown when there is a notification
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    try {
      return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            icon: 'ww_logo', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      );
    } catch (e) {
      print('error: $e');
    }
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    try {
      return notificationsPlugin.show(
          id, title, body, await notificationDetails());
    } catch (e) {
      print('error: $e');
    }
  }

  Future scheduleNotification({
    int id = 1,
    String? title,
    String? body,
    String? payLoad,
    required DateTime scheduleNotificationDateTime,
    required BuildContext context,
  }) async {
    try {
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
              UILocalNotificationDateInterpretation.absoluteTime);
    } catch (e) {
      print('error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scheduling notification: $e'),
          duration: const Duration(seconds: 3), 
        ),
      );
    }
  }
}
