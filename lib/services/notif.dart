import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/page/task.dart';
// import 'package:permission_handler/permission_handler.dart';

class Notif {
  static Future<void> initNotif() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'task_channel',
          channelName: 'Task Notifications',
          channelDescription: 'Notifications for task reminders',
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF5B67CA),
          ledColor: Colors.white,
        )
      ],
      debug: true,
    );

    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // if (await Permission.scheduleExactAlarm.request().isDenied) {
    //   debugPrint("Exact alarm permission denied");
    // }
  }

  static Future<void> listenerNotif() async {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod);
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    AwesomeNotifications().incrementGlobalBadgeCounter();
    debugPrint("Notif tampil");
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint("Notif di klik");
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      MyApp.navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (context) => const TaskPage()));
    }
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    AwesomeNotifications().decrementGlobalBadgeCounter();
    debugPrint("Notif di hapus");
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("notif berhasil dibuat");
  }

  static Future<void> scheduleNotif(
      {required int id,
      required String title,
      required String body,
      required DateTime dateTime}) async {
    debugPrint(dateTime.toString());
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'task_channel',
          title: title,
          body: body,
        ),
        schedule: NotificationCalendar(
          year: dateTime.year,
          month: dateTime.month,
          day: dateTime.day,
          hour: dateTime.hour,
          minute: dateTime.minute,
          second: 0,
          millisecond: 0,
          allowWhileIdle: true,
          preciseAlarm: true,
        ));
  }

  static Future<void> cancelScheduledNotif(int id) async {
    await AwesomeNotifications().cancelSchedule(id);
    debugPrint("cheduled notif dengan id $id sudah di cancel");
  }
}
