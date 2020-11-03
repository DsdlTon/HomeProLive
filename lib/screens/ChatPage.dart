import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:test_live_app/controllers/notification.dart';

import 'LivePage.dart';

class ChatPage extends StatefulWidget {
  final String title;
  final String channelName;
  final String username;
  final String liveAdmin;

  const ChatPage({
    Key key,
    this.title,
    this.channelName,
    this.username,
    this.liveAdmin,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatroomController = new TextEditingController();
  bool isNewChatRoom = true;
  bool isLive;

  File _image;
  String _uploadedFileURL = '';
  String path;
  final picker = ImagePicker();

  //---------------------------------------------------------

  @override
  void initState() {
    super.initState();
    //update userRead
    FireStoreClass.userReaded(widget.channelName, widget.username);
    
    checkIsLive(widget.channelName);
    print('init');
    print('title: ${widget.title}');
    print('adminProfile :assets/logo.png');
    print('liveAdmin ${widget.liveAdmin}');
    print('channelName ${widget.channelName}');
    print('username ${widget.username}');
    NotificationController.instance.setRouteName('/${widget.channelName}${widget.username}');
    print('routeName: ${NotificationController.instance.routeName}');
  }

  @override
  void dispose(){
    NotificationController.instance.routeName = null;
    super.dispose();

  }

  Future getImageFromGallery() async {
    // ignore: deprecated_member_use
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
        path = basename(_image.path);
      });
    });
    uploadFile(widget.channelName, widget.username);
  }

  Future getImageFromCamera() async {
    // ignore: deprecated_member_use
    await ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      setState(() {
        _image = image;
        path = basename(_image.path);
      });
    });
    uploadFile(widget.channelName, widget.username);
  }

  Future uploadFile(channelName, username) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chats/$channelName$username/$path');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
        print('_uploadedFileURL: $_uploadedFileURL');
      });
    });
  }

  Future<void> checkIsLive(channelName) async {
    print('ENTER ISLIVE');
    return await Firestore.instance
        .collection("CurrentLive")
        .document(channelName)
        .get()
        .then((data) {
      setState(() {
        isLive = data["onLive"];
        print("isLive: $isLive");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              colors: [
                Colors.blue[600],
                Colors.blue[700],
                Colors.blue[800],
                Colors.blue[800],
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          "${widget.title}'s Admin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        actions: <Widget>[
          isLive == true ? backToLiveButton(context) : Container(),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              reverse: true,
              shrinkWrap: true,
              children: <Widget>[
                buildChat(),
              ],
            ),
          ),
          bottomBar(context),
          //preview image
          _uploadedFileURL != ''
              ? Container(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.file(_image),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _uploadedFileURL = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget backToLiveButton(context) {
    return IconButton(
      icon: Icon(
        Icons.live_tv,
        color: Colors.white,
      ),
      onPressed: () {
        print('onPreassed');
        print('title: ${widget.title}');
        print('adminProfile assets/logo.png');
        print('liveAdmin ${widget.liveAdmin}');
        print('channelName ${widget.channelName}');
        print('username ${widget.username}');
        Navigator.pushNamed(
          context,
          '/livePage',
          arguments: LivePage(
            title: widget.title,
            adminProfile: 'assets/logo.png',
            liveAdmin: widget.liveAdmin,
            channelName: widget.channelName,
            username: widget.username,
          ),
        );
      },
    );
  }

  Widget buildChat() {
    return Container(
      child: Column(
        children: <Widget>[
          StreamBuilder(
            stream: FireStoreClass.getChatMessage(
                widget.channelName, widget.username),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue[800],
                  ),
                );
              } else {
                if (snapshot.data.documents.length == 0) {
                  isNewChatRoom = true;
                } else if (snapshot.data.documents.length != 0) {
                  isNewChatRoom = false;
                }
                return ListView.builder(
                  padding: EdgeInsets.only(top: 15),
                  physics: NeverScrollableScrollPhysics(),
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    var chatMsgSnap = snapshot.data.documents[index];
                    Timestamp timestamp = chatMsgSnap['timeStamp'];
                    var date = timestamp.toDate();
                    String formattedDate =
                        DateFormat('dd MMM kk:mm').format(date);
                    return chatMsgSnap['role'] == 'user'
                        ? userChatBubble(
                            chatMsgSnap: chatMsgSnap,
                            formattedDate: formattedDate,
                            context: context,
                          )
                        : adminChatBubble(
                            chatMsgSnap: chatMsgSnap,
                            formattedDate: formattedDate,
                            context: context,
                          );
                  },
                );
              }
            },
          ),
          isNewChatRoom == false
              ? getAdminReadState(widget.channelName, widget.username)
              : Text(''),
        ],
      ),
    );
  }

  Widget userChatBubble({chatMsgSnap, formattedDate, context}) {
    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          chatMsgSnap['url'] != ''
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        '$formattedDate',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/fullImageScreen',
                          arguments: chatMsgSnap['url'],
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        height: MediaQuery.of(context).size.height * 0.45,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          child: Image.network(
                            chatMsgSnap['url'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          chatMsgSnap['msg'] != ""
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      colors: [
                        Colors.blue[500],
                        Colors.blue[700],
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  margin: EdgeInsets.only(top: 3.0, bottom: 3.0),
                  padding:
                      EdgeInsets.only(left: 20, right: 15, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$formattedDate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '${chatMsgSnap['msg']}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget adminChatBubble({chatMsgSnap, formattedDate, context}) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chatMsgSnap['url'] != ''
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/fullImageScreen',
                          arguments: chatMsgSnap['url'],
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        height: MediaQuery.of(context).size.height * 0.45,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: Image.network(
                            chatMsgSnap['url'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        '$formattedDate',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          chatMsgSnap['msg'] != ""
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[300],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  margin: EdgeInsets.only(top: 3.0, bottom: 3.0),
                  padding:
                      EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$formattedDate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        '${chatMsgSnap['msg']}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget bottomBar(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: MediaQuery.of(context).size.height * 0.09,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          colors: [
            Colors.blue[700],
            Colors.blue[600],
            Colors.blue[800],
          ],
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.image),
            iconSize: 25.0,
            color: Colors.white,
            onPressed: () {
              getImageFromGallery();
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            iconSize: 25.0,
            color: Colors.white,
            onPressed: () {
              getImageFromCamera();
            },
          ),
          SizedBox(width: 5),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: chatroomController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Aa',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          sentButton(),
        ],
      ),
    );
  }

  Widget sentButton() {
    return Container(
      child: IconButton(
        icon: Icon(
          Icons.send,
          color: Colors.white,
        ),
        iconSize: 25.0,
        onPressed: () {
          String chatText = chatroomController.text.trim();
          //if TextField has Text
          if (chatText != null && chatText.isNotEmpty) {
            if (isNewChatRoom == true) {
              FireStoreClass.setupChatroom(
                widget.channelName,
                widget.username,
                widget.title,
              );
              FireStoreClass.saveChatMessage(
                username: widget.username,
                url: _uploadedFileURL,
                chatText: chatText,
                channelName: widget.channelName,
              );
              chatroomController.clear();
              setState(() {
                _uploadedFileURL = '';
                isNewChatRoom = false;
              });
            } else {
              FireStoreClass.saveChatMessage(
                username: widget.username,
                url: _uploadedFileURL,
                chatText: chatText,
                channelName: widget.channelName,
              );
              chatroomController.clear();
              setState(() {
                _uploadedFileURL = '';
              });
            }
            //check if it has selected image
          } else if (_uploadedFileURL != '') {
            if (isNewChatRoom == true) {
              FireStoreClass.setupChatroom(
                widget.channelName,
                widget.username,
                widget.title,
              );
            }
            FireStoreClass.saveChatMessage(
              username: widget.username,
              url: _uploadedFileURL,
              chatText: chatText,
              channelName: widget.channelName,
            );
            FireStoreClass.setLastMsgWhenSentImage(
                widget.channelName, widget.username);
            setState(() {
              _uploadedFileURL = '';
            });
          } else {
            return print('enter null');
          }
        },
      ),
    );
  }

  Widget showAvatar(context) {
    return Container(
      color: Colors.blue[300],
      padding: EdgeInsets.only(left: 3.0, right: 3.0),
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.046,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.042,
          backgroundImage: AssetImage(
            'assets/homeproLogo.png',
          ),
        ),
      ),
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
          return CircularProgressIndicator(
            backgroundColor: Colors.blue[800],
          );
        }
        var chatroomSnap = snapshot.data;
        if (!snapshot.hasData) {
          return CircularProgressIndicator(
            backgroundColor: Colors.blue[800],
          );
        } else if (chatroomSnap["isAdminRead"] == true) {
          return Container(
            padding: EdgeInsets.only(right: 3),
            alignment: Alignment.topRight,
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: Text(
              'Read',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
