import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:test_live_app/controllers/firebaseDB.dart';

class NotificationController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<String> userToken = [];
  List<String> oldToken = [];

  static NotificationController get instance => NotificationController();

  Future takeFCMTokenWhenAppLaunch() async {
    try {
      if (Platform.isIOS) {
        _firebaseMessaging
            .requestNotificationPermissions(IosNotificationSettings());
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.get('FCMToken');
      String username = 'tester1';

      print('********** Exists FCMToken: $token ***********');
      if (token == null) {
        _firebaseMessaging.getToken().then((token) async {
          prefs.setString('FCMToken', token);
          print('********** FCMToken: ' + token + '**********');
          // check if it has oldToken List in DB?
          if (Firestore.instance.collection('Users').document(username) !=
              null) {
            print('YES!!!!');
            // if Yes
            // get oldUserToken List from DB (name as userToken List)
            await Firestore.instance
                .collection('Users')
                .document(username)
                .get()
                .then((snapshot) {
              oldToken = List.from(snapshot['FCMToken']);
              // print('oldToken: $oldToken');
            });
            print('oldToken: $oldToken');
            // make oldToken = userToken
            userToken = oldToken;
          }
          print(
              '!! userToken before: $userToken !!');
          // if No
          // add newUserToken in userTokenList
          userToken.add(token);
          print(
              '!! userToken after: $userToken !!');
          //if Username is Existed in system
          if (username != null) {
            // save userTokenList to DB
            FireStoreClass.instanace.saveUserToken(username, userToken);
          }
        });
      }

      _firebaseMessaging.configure(
        // call when app is in the foreground
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          String msg = 'notibody';
          String name = 'chatapp';
          if (Platform.isIOS) {
            msg = message['aps']['alert']['body'];
            name = message['aps']['alert']['title'];
          } else {
            msg = message['notification']['body'];
            name = message['notification']['title'];
          }

          String currentChatRoom = (prefs.get('currentChatRoom') ?? 'None');

          if (Platform.isIOS) {
            if (message['chatroomid'] != currentChatRoom) {
              sendLocalNotification(name, msg);
            }
          } else {
            if (message['data']['chatroomid'] != currentChatRoom) {
              sendLocalNotification(name, msg);
            }
          }

          // FireStoreClass.instanace.getUnreadMSGCount();
        },

        // onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
        // call when app has been close completely and it's opened form the noti directly
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        // call when the app is in the background and opened by noti directly
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );
    } catch (e) {
      print(e.message);
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
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    }
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  Future _selectNotification(String payload) async {}

  sendLocalNotification(name, msg) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin
        .show(0, name, msg, platformChannelSpecifics, payload: 'item x');
  }

  Future<void> sendNotificationMessage(
      messageType, msg, senderName, chatRoomID, targetUserToken) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAn00GHMI:APA91bGlkavV8tSqb9xptjUCkA-0oiXl0Ben3Vx3PeRo4SNc5H9fIBVle5c9csZVJUqQXzCC73W1iZSn_jsWp8Gr7TGCHMeBTLI0KO-36SGV4TBV-0scqd2onx0Lq8QeOllAyZd5aCwp',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': messageType == 'text' ? '$msg' : '(Photo)',
            'title': '$senderName',
            // 'badge': '$unReadMSGCount' //'$unReadMSGCount'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'chatroomid': chatRoomID,
          },
          'to': targetUserToken,
        },
      ),
    );
  }
}

// await Firestore.instance
//     .collection('Users')
//     .document(username)
//     .get()
//     .then((snapshot) {
//   List<String> oldToken = List.from(snapshot['FCMToken']);
//   print('************ 3. oldToken: $oldToken ************');
//   oldToken.forEach((token) {
//     userToken.add(token);
//     print('4. $userToken');
//   });
// });
