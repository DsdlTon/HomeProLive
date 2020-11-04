import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_live_app/animations/floatUpAnimation.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:test_live_app/screens/ChatPage.dart';
import 'package:test_live_app/widgets/logoutDialog.dart';

class AllChatPage extends StatefulWidget {
  final String title;
  final String liveAdmin;
  final String channelName;

  const AllChatPage({
    Key key,
    this.title,
    this.liveAdmin,
    this.channelName,
  }) : super(key: key);

  @override
  _AllChatPageState createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  String username = '';
  Cart _cartData = Cart();
  String _accessToken;
  int cartLen = 0;

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    return username;
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    setState(() {
      _accessToken = accessToken;
    });
    return _accessToken;
  }

  Future<Cart> getUserCartData() async {
    print('ENTER GETUSERCARTDATA');
    final headers = {
      "access-token": _accessToken,
    };
    print(headers);
    return CartService.getUserCart(headers);
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getAccessToken().then((accessToken) {
      getUserCartData().then((cartData) {
        setState(() {
          _cartData = cartData;
          cartLen = _cartData.cartDetails.length;
        });
        print('cartLen: $cartLen');
      });
    });
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
        leading: FloatUpAnimation(
          0.5,
          signOutButton(),
        ),
        title: FloatUpAnimation(
          0.5,
          Text(
            'Chats',
            style: TextStyle(fontSize: 15),
          ),
        ),
        actions: <Widget>[
          FloatUpAnimation(
            0.5,
            cartButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(bottom: 5),
          child: StreamBuilder(
            stream: FireStoreClass.getChatroom(),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        CircularProgressIndicator(
                          backgroundColor: Colors.blue[800],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
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
                    // print('//// ${snapshot.data.documents.length}');

                    return usernameInFB == username
                        ? GestureDetector(
                            onTap: () {
                              print('From allChatPage');
                              print('title: $title');
                              print('adminProfile ${'assets/logo.png'}');
                              print('liveAdmin ${widget.liveAdmin}');
                              print('channelName $channelName');
                              print('username $username');
                              Navigator.pushNamed(
                                context,
                                '/chatPage',
                                arguments: ChatPage(
                                  title: title,
                                  channelName: channelName,
                                  username: username,
                                  liveAdmin: 'Homepro1',
                                ),
                              );
                            },
                            child: chatCard(snapshot, index, formattedDate),
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

  Widget noChat() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.79,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FloatUpAnimation(
              0.2,
              Icon(Icons.remove_circle_outline,
                  color: Colors.grey[400], size: 60),
            ),
            SizedBox(height: 10),
            FloatUpAnimation(
              0.4,
              Text(
                'No Order History',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget trashBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.red,
      ),
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  Widget chatCard(snapshot, index, formattedDate) {
    return Dismissible(
      key: ValueKey(snapshot.data.documents[index]['title']),
      background: trashBg(),
      onDismissed: (direction) {
        print('Enter onDismissible');
        FireStoreClass.deleteChatroom();
        setState(() {
          print('Enter setState');
          snapshot.data.documents.removeAt(index);
        });
      },
      direction: DismissDirection.endToStart,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue[800],
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage('assets/homeproLogo.png'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                snapshot.data.documents[index]['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  constraints: BoxConstraints(
                                    minWidth: 0,
                                    maxWidth: 170,
                                  ),
                                  child: Text(
                                    snapshot.data.documents[index]['lastMsg'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: snapshot.data.documents[index]
                                                ['isUserRead'] ==
                                            false
                                        ? TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          )
                                        : TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    ' · $formattedDate',
                                    style: TextStyle(
                                      color: Colors.grey[600],
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
            snapshot.data.documents[index]['isUserRead'] == false
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
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
          tooltip: 'Cart',
          onPressed: () {
            Navigator.of(context).pushNamed('/cartPage').then((value) {
              getUserCartData().then((cartData) {
                setState(() {
                  _cartData = cartData;
                  cartLen = _cartData.cartDetails.length;
                });
                print('cartLen: $cartLen');
              });
            });
          },
        ),
        cartLen != 0
            ? Positioned(
                top: 5,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text('$cartLen'),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget signOutButton() {
    return IconButton(
      icon: Icon(
        Icons.exit_to_app,
        color: Colors.white,
      ),
      tooltip: 'Logout',
      onPressed: () {
        print('OUT');
        showDialog(
          context: context,
          builder: (BuildContext context) => LogoutDialog(username: username),
        );
      },
    );
  }
}
