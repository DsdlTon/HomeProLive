// import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/screens/ChatPage.dart';

import '../main.dart';

class NotificationController {
  String routeName;
  String title;
  String liveAdmin;
  DocumentSnapshot chatroomSnap;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationController _instance = NotificationController._();

  NotificationController._();

  static NotificationController get instance => _instance;

  void setRouteName(name) {
    routeName = name;
  }

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
            //TODO: IoS Section
          } else {
            body = message['notification']['body'];
            title = message['notification']['title'];
            print('BEFORE ENTER SENTLOCAL');
            print('BODY: $body TITLE: $title');
            String chatroomId = message['data']['chatroomid'];
            if (routeName != '/$chatroomId') {
              sendLocalNotification(title, body, chatroomId);
            }
          }
        },
        // call when the app is in the background and opened by noti directly
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          String chatroomId = message['data']['chatroomid'];
          navigateToChatPage(chatroomId);
        },
        // call when app has been close completely and it's opened form the noti directly
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          String chatroomId = message['data']['chatroomid'];
          navigateToChatPage(chatroomId);
        },
      );
    } catch (e) {
      print(e.message);
    }
  }

  Future<void> getChatroomDoc(channelName, username) async {
    await Firestore.instance
        .collection("Chatroom")
        .document(channelName + username)
        .get()
        .then((snapshot) {
      chatroomSnap = snapshot;
    });
  }

  void navigateToChatPage(chatroomId) {
    if (Platform.isIOS) {
      //TODO: IoS Section
    } else {
      print('Android navigateToChatPage($chatroomId)');
      int len = chatroomId.length;
      String channelName = chatroomId.substring(0, 13);
      String username = chatroomId.substring(13, len);
      getChatroomDoc(channelName, username).then(
        (value) {
          print('GET CHATROOMDOC');
          print('chatroomId: $chatroomId');
          print('channelName: $channelName');
          print('username: $username');
          print('liveAdmin: ${chatroomSnap['liveAdmin']}');
          print('title: ${chatroomSnap['title']}');

          MyApp.navigatorKey.currentState.pushNamed(
            '/chatPage',
            arguments: ChatPage(
              channelName: channelName,
              username: username,
              title: chatroomSnap['title'],
              liveAdmin: chatroomSnap['liveAdmin'],
            ),
          );
        },
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

  Future _selectNotification(chatroomId) async {
    print("onSelectNotification called.");
    print(chatroomId);
    if (chatroomId != null) {
      navigateToChatPage(chatroomId);
    }
    // print("onSelectNotification called.");
  }

  sendLocalNotification(title, body, chatroomId) async {
    print('enter sendLocalNotification');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '10000', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    print('title: $title');
    print('body: $body');
    await _flutterLocalNotificationsPlugin
        .show(1, title, body, platformChannelSpecifics, payload: chatroomId);
  }
}
