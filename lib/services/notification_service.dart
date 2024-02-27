import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("flutter_logo");

  final DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  void initialNotification () async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  void sendNotification({
    required String title,
    required String body,
  }) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "channelId",
      "channelName",
      icon: "flutter_logo",
      importance: Importance.max,
      priority: Priority.max
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails);
  }

  static int notificationCounter = 0;

  static int getCounter() {
    return notificationCounter;
  }

  static void incrementCounter() {
    notificationCounter++;
  }

  void scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledNotificationDateTime,
  }) async {
    NotificationService.incrementCounter();

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduledNotificationDateTime,
      tz.local,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        "channelId",
        "channelName",
        icon: "flutter_logo",
        importance: Importance.max,
        priority: Priority.max
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationCounter,
        title,
        body,
        scheduledDate,
        notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void cancelScheduledNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}
