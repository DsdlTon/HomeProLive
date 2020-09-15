import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:test_live_app/pages/ChatPage.dart';

class RecentForegroundLive extends StatefulWidget {
  final String title;
  final String userProfile;
  final String liveUser;
  final String username;
  final String channelName;

  RecentForegroundLive(
      {this.title,
      this.channelName,
      this.userProfile,
      this.liveUser,
      this.username});

  @override
  _RecentForegroundLiveState createState() => _RecentForegroundLiveState();
}

class _RecentForegroundLiveState extends State<RecentForegroundLive> {
  TextEditingController chatController = TextEditingController();
  String chatText;
  FocusNode focusNode;
  int _keyboardVisibilitySubscriberId;
  bool _keyboardState;
  var token;

  int commentIndex = 0; //yes
  int commentLen; //yes
  int startLiveTime; //yes
  int firstCommentTime; //commentTime[commentIndex]
  int lastCommentTime = 1599640062717;
  int timer = 100; //yes

  List<String> allComment = []; //yes
  List<String> pushedComment = []; //wait for allComment to push data in.

  KeyboardVisibilityNotification _keyboardVisibility =
      KeyboardVisibilityNotification();

  void getDatatoPlaybackComment() {
    startLiveTime = int.parse(widget.channelName);
    getDataFromFirebase();
  }

  Future<void> getDataFromFirebase() async {
    var totalComment = Firestore.instance
        .collection("CurrentLive")
        .document(widget.channelName)
        .collection("Chats")
        .orderBy("timeStamp", descending: false);
    var querySnapshot = await totalComment.getDocuments();
    //get commentLen
    commentLen = querySnapshot.documents.length;
    //get allComment[]
    for (int i = 0; i < commentLen; i++) {
      allComment.add(querySnapshot.documents[i]['msg']);
    }
    print('commentLen: $commentLen');
    print('allComment: $allComment');
  }

// --------------------------------------------------------

  Timer _timer;
  int _start = 10;

  void counter() {
    const milliSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      milliSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start + 1;
          }
        },
      ),
    );
  }

// -------------------------------------------------------
  @protected
  void initState() {
    super.initState();
    getDatatoPlaybackComment();
    counter();
    FireStoreClass.saveViewer(
      widget.username,
      widget.liveUser,
      widget.channelName,
    );

    Firestore.instance
        .collection("Users")
        .document(widget.username)
        .get()
        .then((snapshot) {
      token = snapshot['FCMToken'];
      // assert(token is String);
      print('Retrived Token: $token');
      return token;
    });

    _keyboardState = _keyboardVisibility.isKeyboardVisible;
    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        setState(() {
          _keyboardState = visible;
          if (_keyboardState != true) {
            setState(() {
              chatController.clear();
              FocusScope.of(context).unfocus();
            });
          }
        });
      },
    );

    focusNode = FocusNode();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    FireStoreClass.deleteViewers(
        username: widget.username, channelName: widget.channelName);
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var height = MediaQuery.of(context).size.height;
    double heightWithSafeArea = height - padding.top - padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: heightWithSafeArea,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                liveHeader(),
                _keyboardState == false
                    ? liveBottom()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: chatPanel(),
                          ),
                          showChatTextField(),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget liveHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 10.0),
                showUserInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget liveBottom() {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            child: chatPanel(),
          ),
          bottomBar(),
        ],
      ),
    );
  }

  Widget showChatTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
      ),
      child: TextField(
        focusNode: focusNode,
        style: TextStyle(color: Colors.white),
        controller: chatController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Aa',
          hintStyle: TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: () {
              chatText = chatController.text;
              if (chatText == null || chatText.isEmpty) {
                return print('Enter null');
              } else {
                FireStoreClass.saveChat(
                  widget.username,
                  chatText,
                  widget.channelName,
                  token,
                );
              }
              FocusScope.of(context).unfocus();
              chatController.clear();
            },
          ),
        ),
      ),
    );
  }

  Widget favIcon({icon, onPressed}) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.2),
      ),
      child: IconButton(
        icon: Icon(Icons.favorite, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget chatIcon({icon, onPressed}) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.2),
      ),
      child: IconButton(
        icon: Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                title: widget.title,
                channelName: widget.channelName,
                username: widget.username,
                liveUser: widget.liveUser,
                fcmToken: token,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                showItemList(),
                fakeChatTextField(),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  chatIcon(),
                  // favIcon(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showItemList() {
    return IconButton(
      icon: Icon(Icons.list, color: Colors.white, size: 30),
      onPressed: () {
        bottomSheet();
      },
    );
  }

  PersistentBottomSheetController bottomSheet() {
    return showBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'All Product',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.0,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.47,
                child: ListView.builder(
                  itemBuilder: (context, position) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          position.toString(),
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget chatPanel() {
    return Container(
      width: MediaQuery.of(context).size.height / 2.7,
      child: Text(
        "$_start",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget fakeChatTextField() {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
        setState(() {
          _keyboardState = true;
        });
      },
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width / 1.5,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Aa',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget showUserInfo() {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 14.0,
          backgroundImage: AssetImage(widget.userProfile),
          backgroundColor: Colors.blue[800],
        ),
        SizedBox(width: 5.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.liveUser,
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
            SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 12.0,
                ),
                SizedBox(width: 5.0),
                Center(
                  child: StreamBuilder(
                    stream: FireStoreClass.getViewer(
                        widget.liveUser, widget.channelName),
                    builder: (BuildContext context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        int viewers = snapshot.data.documents.length;
                        return Text(
                          viewers.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
