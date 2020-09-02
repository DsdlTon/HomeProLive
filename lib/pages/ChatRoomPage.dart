import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/services/firebaseDB.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  final String title;
  final String channelName;
  final String username;
  final String liveUser;

  ChatRoomPage({
    this.title,
    this.channelName,
    this.username,
    this.liveUser,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController chatroomController = new TextEditingController();
  bool isNewChatRoom = true;
  // FocusNode focusNode;

  Future<String> totalChat(channelName, username) async {
    var chatQuery = Firestore.instance
        .collection('Chatroom')
        .document(channelName + username)
        .collection('ChatMessage');

    var querySnapshot = await chatQuery.getDocuments();
    int totalChat = querySnapshot.documents.length;
    return totalChat.toString();
  }

  @override
  void initState() {
    super.initState();
    //Tell Admin side That User has been Readed
    FireStoreClass.userReaded(widget.channelName, widget.username);

    // focusNode = FocusNode();
    // focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    print('======================build========================');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "Talk with ${widget.title}'s Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              getAdminReadState(widget.channelName, widget.username)
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          // height: availableHeight,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              chatPanel(availableHeight),
              bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatPanel(availableHeight) {
    return Container(
      color: Colors.white,
      height: availableHeight - MediaQuery.of(context).size.height / 12.5,
      width: MediaQuery.of(context).size.width * 0.95,
      child: chatBubble(),
    );
  }

  Widget chatBubble() {
    return StreamBuilder(
      stream:
          FireStoreClass.getChatMessage(widget.channelName, widget.username),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            isNewChatRoom = true;
          } else if (snapshot.data.documents.length != 0) {
            isNewChatRoom = false;
          }
          return ListView.builder(
            reverse: true,
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int index) {
              var chatMsgSnap = snapshot.data;
              //get Formatted Date------------------------------------------
              Timestamp timestamp = chatMsgSnap.documents[index]['timeStamp'];
              var date = timestamp.toDate();
              String formattedDate = DateFormat('kk:mm').format(date);
              //------------------------------------------------------------
              return chatMsgSnap.documents[index]['role'] == 'user'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '$formattedDate',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          margin: EdgeInsets.only(top: 4, bottom: 4),
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(3),
                                ),
                                color: Colors.blue[700]),
                            child: Text(
                              '${snapshot.data.documents[index]['msg']}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.blue[800],
                              child: CircleAvatar(
                                radius: 15,
                                backgroundImage:
                                    AssetImage('assets/homeproLogo.png'),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(3),
                                ),
                                color: Colors.grey,
                              ),
                              child: Text(
                                '${snapshot.data.documents[index]['msg']}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '$formattedDate',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
            },
          );
        }
      },
    );
  }

  Widget getAdminReadState(channelName, username) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Chatroom')
          .document(channelName + username)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        //Chatroom Field
        var chatroomSnap = snapshot.data;

        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else if (chatroomSnap['isAdminRead'] == true) {
          return Text(
            'Read by Admin',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget bottomBar() {
    return Container(
      color: Colors.blue[800],
      child: Row(
        children: [
          chatTextField(),
          sentButton(),
        ],
      ),
    );
  }

  Widget chatTextField() {
    return Container(
      color: Colors.blue[800],
      width: MediaQuery.of(context).size.width * 0.85,
      child: Row(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.07,
            width: MediaQuery.of(context).size.width * 0.8,
            margin: EdgeInsets.all(2),
            padding: EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: TextField(
              // focusNode: focusNode,
              style: TextStyle(color: Colors.black),
              controller: chatroomController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Aa',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sentButton() {
    return Container(
      child: IconButton(
        icon: Icon(Icons.send, color: Colors.white),
        onPressed: () {
          String chatText = chatroomController.text;
          if (chatText == null || chatText.isEmpty) {
            return print('Enter null');
          } else if (isNewChatRoom == true) {
            FireStoreClass.setupChatroom(
                widget.channelName, widget.username, widget.title);
            FireStoreClass.saveChatMessage(
              username: widget.username,
              chatText: chatText,
              channelName: widget.channelName,
            );
            chatroomController.clear();
            setState(() {
              isNewChatRoom = false;
            });
          } else {
            FireStoreClass.saveChatMessage(
              username: widget.username,
              chatText: chatText,
              channelName: widget.channelName,
            );
            chatroomController.clear();
          }
        },
      ),
    );
  }
}
