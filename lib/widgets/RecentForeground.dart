import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:test_live_app/screens/ChatPage.dart';

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
  var token;
  var querySnapshot;

  int commentIndex = 0; //yes
  int commentLen; //yes
  int startLiveTime; //yes
  int currentCommentTime; //currentCommentTime[commentIndex]
  int lastCommentTime;
  int timer = 100; //yes
  Timer _timer;
  List<String> allComment = []; //yes
  List<String> pushedComment = []; //wait for allComment to push data in.
  List<String> allUsername = [];
  List<String> pushedUsername = [];

  Future<void> getDataFromFirebase() async {
    startLiveTime = int.parse(widget.channelName);

    var totalComment = Firestore.instance
        .collection("CurrentLive")
        .document(widget.channelName)
        .collection("Chats")
        .orderBy("timeStamp", descending: true);
    querySnapshot = await totalComment.getDocuments();

    //get commentLen
    commentLen = querySnapshot.documents.length;

    //get allComment[]
    for (int i = 0; i < commentLen; i++) {
      allComment.add(querySnapshot.documents[i]['msg']);
    }

    //get FirstUsername
    for (int i = 0; i < commentLen; i++) {
      allUsername.add(querySnapshot.documents[i]['username']);
    }

    // get firstCommentTime
    Timestamp ftimestamp = querySnapshot.documents[commentLen - 1]['timeStamp'];
    var fdate = ftimestamp.toDate();
    currentCommentTime = fdate.millisecondsSinceEpoch;

    Timestamp ltimestamp = querySnapshot.documents[0]['timeStamp'];
    var ldate = ltimestamp.toDate();
    lastCommentTime = ldate.millisecondsSinceEpoch;

    commentIndex = commentLen - 1;

    print('START commentLen: $commentLen');
    print('START allComment: $allComment');
    print('START startLiveTime: $startLiveTime');
    print('START lastComment: $lastCommentTime');
    print('START commentIndex: $commentIndex');
    print('START currentCommentTime: $currentCommentTime');
  }

  void replayComment() {
    const milliSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      milliSec,
      (Timer timer) => setState(
        () {
          if (startLiveTime > lastCommentTime) {
            timer.cancel();
          } else {
            startLiveTime += 100;
            if (startLiveTime > currentCommentTime) {
              pushComment();
              setNextCommentTime();
            }
          }
        },
      ),
    );
  }

  void pushComment() {
    pushedComment.add(allComment[commentIndex]);
    pushedUsername.add(allUsername[commentIndex]);
    print('pushComment: $pushedComment');
    print('pushUsername: $pushedUsername');
  }

  void setNextCommentTime() async {
    if (commentIndex > 0) {
      commentIndex -= 1;
      print('NEW commentIndex: $commentIndex');

      Timestamp ctimestamp = querySnapshot.documents[commentIndex]['timeStamp'];
      var cdate = ctimestamp.toDate();
      currentCommentTime = cdate.millisecondsSinceEpoch;

      String comment = querySnapshot.documents[commentIndex]['msg'];
      print('NEXT commentTime: $currentCommentTime');
      print('NEXT comment: $comment');
    } else {
      commentIndex = 0;
    }
  }

// -------------------------------------------------------
  @protected
  void initState() {
    super.initState();
    getDataFromFirebase();
    replayComment();
    FireStoreClass.saveViewer(
      widget.username,
      widget.liveUser,
      widget.channelName,
    );
  }

  @override
  void dispose() {
    super.dispose();
    FireStoreClass.deleteViewers(
        username: widget.username, channelName: widget.channelName);
    _timer.cancel();
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
                liveBottom(),
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
          Navigator.pushNamed(
            context,
            '/chatPage',
            arguments: ChatPage(
              title: widget.title,
              channelName: widget.channelName,
              username: widget.username,
              liveUser: widget.liveUser,
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
            showItemList(),
            chatIcon(),
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

  List product;
  Future<List<dynamic>> getProductList(channelName) async {
    await Firestore.instance
        .collection("CurrentLive")
        .document(channelName)
        .get()
        .then((snapshot) {
      product = snapshot['productInLive'];
      print('PRODUCT: $product');
      print('PRODUCT LEN: ${product.length}');
    });
    return product;
  }

  PersistentBottomSheetController bottomSheet() {
    return showBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      builder: (context) {
        return FutureBuilder(
          future: getProductList(widget.channelName),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Products (${product.length})',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.white, size: 18),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.47,
                        child: ListView.builder(
                          itemCount: product.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              color: Colors.black.withOpacity(0.3),
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      child: Image.network(
                                        product[index]['image'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.03),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          product[index]['title'],
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        Text(
                                          '฿ ' + product[index]['price'],
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.add_shopping_cart,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget chatPanel() {
    return Container(
      width: MediaQuery.of(context).size.height / 2.7,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: ListView.builder(
            shrinkWrap: true,
            // reverse: true,
            itemCount: pushedComment.length,
            itemBuilder: (BuildContext context, index) {
              return RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '${pushedUsername[index]}: ',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${pushedComment[index]}',
                    ),
                  ],
                ),
              );
            }),
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
