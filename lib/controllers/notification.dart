// import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/screens/ChatPage.dart';

import '../main.dart';

class NotificationController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static NotificationController get instance => NotificationController();

  Future subscribeWhenAppLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');

    try {
      _firebaseMessaging.subscribeToTopic(username);
      _firebaseMessaging.subscribeToTopic('live');
      _firebaseMessaging.configure(
        // call when app is in the foreground
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          String title = 'title';
          String body = 'body';
          if (Platform.isIOS) {
            body = message['aps']['alert']['body'];
            title = message['aps']['alert']['title'];
            sendLocalNotification(title, body);
          } else {
            body = message['notification']['body'];
            title = message['notification']['title'];
            print('BEFORE ENTER SENTLOCAL');
            print('BODY: $body TITLE: $title');
            sendLocalNotification(title, body);
            // navigateToChatPage(message);
          }
        },
        // call when the app is in the background and opened by noti directly
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          navigateToChatPage(message);
        },
        // call when app has been close completely and it's opened form the noti directly
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          navigateToChatPage(message);
        },
      );
    } catch (e) {
      print(e.message);
    }
  }

  void navigateToChatPage(message) {
    if (Platform.isIOS) {
      // String chatroomId = message['aps']['alert']['chatroomid'];
      // int len = chatroomId.length;
      // String channelName = chatroomId.substring(0, 13);
      // String username = chatroomId.substring(13, len);
      // MyApp.navigatorKey.currentState.pushNamed(
      //   '/chatPage',
      //   arguments: ChatPage(
      //     title: 'WaitForApi',
      //     channelName: channelName,
      //     username: username,
      //   ),
      // );
    } else {
      String chatroomId = message['data']['chatroomid'];
      int len = chatroomId.length;
      String channelName = chatroomId.substring(0, 13);
      String username = chatroomId.substring(13, len);
      MyApp.navigatorKey.currentState.pushNamed(
        '/chatPage',
        arguments: ChatPage(
          title: 'WaitForApi',
          channelName: channelName,
          username: username,
        ),
      );
    }
  }

  Future initLocalNotification() async {
    if (Platform.isIOS) {
      // set iOS Local notification.
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    } else {
      // set Android Local notification.
      print('ANDROID CASE');
      var initializationSettingsAndroid =
          AndroidInitializationSettings('mipmap/ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    }
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    print("_onDidReceiveLocalNotification called.");
  }

  Future _selectNotification(String payload) async {
    print("onSelectNotification called.");
  }

  sendLocalNotification(title, body) async {
    print('enter sendLocalNotification');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '10000', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    print('enter sendLocalNotification2');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    print('enter sendLocalNotification3');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    print('enter sendLocalNotification4');
    print('title: $title');
    print('body: $body');
    print('platformChannelSpecifics: $platformChannelSpecifics');
    // print('payload: $payload');
    await _flutterLocalNotificationsPlugin.show(
        1, title, body, platformChannelSpecifics);
    print('enter sendLocalNotification5');
  }
}
