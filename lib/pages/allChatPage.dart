import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/pages/ChatPage.dart';

class AllChatPage extends StatefulWidget {
  final String title;
  final String liveUser;
  final String channelName;

  const AllChatPage({Key key, this.title, this.liveUser, this.channelName})
      : super(key: key);

  @override
  _AllChatPageState createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  String username = '';

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    return username;
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.transparent,
          child: CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage('assets/me.jpg'),
          ),
        ),
        title: Text(
          'Chats',
          style: TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          cartButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: 5),
          child: StreamBuilder(
            stream: FireStoreClass.getChatroom(),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue[800],
                  ),
                );
              } else {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  controller: new ScrollController(keepScrollOffset: false),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    Timestamp timestamp =
                        snapshot.data.documents[index]['timeStamp'];
                    var date = timestamp.toDate();
                    String formattedDate =
                        DateFormat('dd MMM kk:mm').format(date);
                    String title = snapshot.data.documents[index]['title'];
                    String channelName =
                        snapshot.data.documents[index]['channelName'];
                    String usernameInFB =
                        snapshot.data.documents[index]['chatWith'];

                    return usernameInFB == username
                        ? Dismissible(
                            key: Key(snapshot.data.documents[index].toString()),
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              color: Colors.red,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                final chats = snapshot.data.documents;
                                chats.removeAt(index);
                              });
                            },
                            direction: DismissDirection.endToStart,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/chatPage',
                                  arguments: ChatPage(
                                    title: title,
                                    channelName: channelName,
                                    username: username,
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                padding: EdgeInsets.all(15),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 0.1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.blue[800],
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundImage: AssetImage(
                                                  'assets/homeproLogo.png'),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Row(
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot.data
                                                              .documents[index]
                                                          ['title'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        Text(
                                                          snapshot.data
                                                                  .documents[
                                                              index]['lastMsg'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: snapshot.data.documents[
                                                                          index]
                                                                      [
                                                                      'isUserRead'] ==
                                                                  false
                                                              ? TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )
                                                              : TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                ),
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            ' · $formattedDate',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    snapshot.data.documents[index]
                                                ['isUserRead'] ==
                                            false
                                        ? Container(
                                            width: 11,
                                            height: 11,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue[700],
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container();
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget appName() {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'HomePro',
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
          TextSpan(
            text: ' Live',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget cartButton() {
    return IconButton(
      icon: Icon(
        Icons.shopping_cart,
        color: Colors.white,
      ),
      tooltip: 'Cart',
      onPressed: () {
        Navigator.of(context).pushNamed('/cartPage');
      },
    );
  }
}
