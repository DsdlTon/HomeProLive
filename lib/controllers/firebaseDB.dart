import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FireStoreClass {
  static FireStoreClass get instanace => FireStoreClass();

  static final Firestore _db = Firestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  static final chatCollection = 'chats';
  String url = '';
  List<String> allUserToken = [];

  // ---Token----------------------------------------------------------------------

  Future<List<String>> getOldUserToken(username) async {
    print('ENTER getUserToken FUNCTION');
    return await _db
        .collection('Users')
        .document(username)
        .get()
        .then((snapshot) {
      List<String> oldToken = List.from(snapshot['FCMToken']);
      print('oldToken: $oldToken');
      return oldToken;
    });
  }

  //userToken that pass in here Included both oldToken and newToken already
  Future<void> saveUserToken(username, userToken) async {
    print('ENTER SAVEUSERTOKEN FUNCTION');
    getUserTokenList(userToken);
    print('SAVE $username, $allUserToken, ${allUserToken.runtimeType}');
    await Firestore.instance.collection('Users').document(username).setData({
      'FCMToken': allUserToken,
    });
  }

  List<String> getUserTokenList(userToken) {
    userToken.forEach((token) {
      print('Enter forEach!!!!!!!!!!!!!!!');
      print('$token');
      allUserToken.add(token.toString());
      print('allUserToken: $allUserToken');
    });
    return allUserToken.toList();
  }

// ---Chat In Live-----------------------------------------------------------------

  static void saveChat(username, chatText, channelName, token) {
    _db
        .collection("CurrentLive")
        .document(channelName)
        .collection("Chats")
        .add({
      'username': username, //username is defined in foreground
      'msg': chatText, //chatText is TextController in Foreground
      'timeStamp': Timestamp.now(),
      'FCMToken': token,
    });
  }

  static Stream<QuerySnapshot> getChat(channelName) {
    return _db
        .collection("CurrentLive")
        .document(channelName)
        .collection("Chats")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

// ---Viewer in Live---------------------------------------------------------------------------

  static void saveViewer(username, liveUser, channelName) {
    _db
        .collection("CurrentLive")
        .document(channelName)
        .collection("Viewers")
        .document(username)
        .setData({
      'liveUser': liveUser,
    });

    print(
        '-------------- save username $username in $liveUser channal -------------------');
  }

  static Stream<QuerySnapshot> getViewer(liveUser, channelName) {
    return _db
        .collection("CurrentLive")
        .document(channelName)
        .collection("Viewers")
        .snapshots();
  }

  static void deleteViewers({username, channelName}) async {
    await _db
        .collection("CurrentLive")
        .document(channelName)
        .collection('Viewers')
        .document(username)
        .delete();
    print('-------------- delete username $username ----------------');
  }

// ---All Live List----------------------------------------------------------------------------------------

  static Stream<QuerySnapshot> getCurrentLive() {
    var snapshot = _db
        .collection("CurrentLive")
        .where("onLive", isEqualTo: true)
        .snapshots();
    return snapshot;
  }

  static Stream<QuerySnapshot> getRecentlyLive() {
    var snapshot = _db
        .collection("CurrentLive")
        .where("onLive", isEqualTo: false)
        .snapshots();
    return snapshot;
  }

  // ---Chatroom List--------------------------------------------------------------------------------------

  static Stream<QuerySnapshot> getChatroom() {
    var snapshot = _db
        .collection("Chatroom")
        .orderBy("timeStamp", descending: true)
        .snapshots();
    return snapshot;
  }

  static void setupChatroom(channelName, username, title) {
    _db.collection("Chatroom").document(channelName + username).setData({
      'channelName': channelName,
      'chatWith': username,
      'title': title,
      'isUserRead': true,
      'isAdminRead': false,
    });
    print(
        '------------------- Setup Chatroom channelName: $channelName$username success --------------------------');
  }

  static void deleteChatroom({channelName, username}) async {
    await _db.collection("Chatroom").document(channelName + username).delete();
    print(
        '-------------------- delete Chatroom channelName: $channelName$username --------------------------------');
  }

  // ---Chat In ChatRoom with Admin-----------------------------------------------------------------

  static void saveChatMessage({username, chatText, channelName, url}) {
    _db.collection("Chatroom").document(channelName + username).updateData(
      {
        'lastMsg': chatText,
        'timeStamp': Timestamp.now(),
        'isAdminRead': false,
      },
    ).then(
      (value) => _db
          .collection("Chatroom")
          .document(channelName + username)
          .collection("ChatMessage")
          .add(
        {
          'username': username, //username is defined in foreground
          'msg': chatText, //chatText is TextController in Foreground,
          'url': url,
          'timeStamp': Timestamp.now(),
          'role': "user",
        },
      ),
    );

    print(
        '---------------- save $chatText in $channelName+$username success --------------------------');
  }

  static Stream<QuerySnapshot> getChatMessage(channelName, username) {
    return _db
        .collection("Chatroom")
        .document(channelName + username)
        .collection("ChatMessage")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  static void setLastMsgWhenSentImage(channelName, username) {
    _db
        .collection("Chatroom")
        .document(channelName + username)
        .updateData({'lastMsg': '$username is sent a photo'});
    print(
        '--------------- $channelName+$username is readed by User --------------------');
  }

  // ---Read Status----------------------------------------------------------------------------
  static void userReaded(channelName, username) {
    _db
        .collection("Chatroom")
        .document(channelName + username)
        .updateData({'isUserRead': true});
    print(
        '--------------- $channelName+$username is readed by User --------------------');
  }

  static Stream<QuerySnapshot> getChatroomData() {
    return _db.collection("Chatroom").snapshots();
  }

}
