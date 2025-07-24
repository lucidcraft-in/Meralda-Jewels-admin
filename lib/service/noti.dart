import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Noti {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        new AndroidInitializationSettings('mipmap-mdpi/ic_launcher.png');
    var iOSInitialize = new DarwinInitializationSettings();
    var initializationsSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  static Future showBigTextNotification(
      {var id = 0,
      String? title,
      String? body,
      @required var payload,
      FlutterLocalNotificationsPlugin? fln}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      "channelId",
      "channelName",
      // "channelDescription",
    );
    // OpenFile.open(payload);
    // AndroidNotificationDetails(
    //   'you_can_name_it_whatever1',
    //   'channel_name',

    //   playSound: true,
    //   sound: RawResourceAndroidNotificationSound('notification'),
    //   importance: Importance.max,
    //   priority: Priority.high,
    // );

    var not = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());

    await fln!.show(
      0,
      title,
      body,
      not,
    );
  }
}
