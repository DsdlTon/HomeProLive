import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/animations/floatUpAnimation.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/screens/RecentLivePage.dart';
import '../widgets/logoutDialog.dart';

class ListRecentlyLivePage extends StatefulWidget {
  @override
  _ListRecentlyLivePageState createState() => _ListRecentlyLivePageState();
}

class _ListRecentlyLivePageState extends State<ListRecentlyLivePage> {
  String username = '';
  Cart _cartData = Cart();
  String _accessToken;
  int cartLen = 0;

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    print('username:' + username);
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
        backgroundColor: Colors.orange[400],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              colors: [
                Colors.yellow[600],
                Colors.yellow[700],
                Colors.yellow[800],
                Colors.yellow[800],
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
        title: Column(
          children: <Widget>[
            FloatUpAnimation(
              0.5,
              appName(),
            ),
            FloatUpAnimation(
              0.5,
              showUsername(),
            ),
          ],
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
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.79,
          padding: EdgeInsets.fromLTRB(5, 5, 5, 3),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: StreamBuilder(
            stream: FireStoreClass.getRecentlyLive(),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.yellow[800],
                  ),
                );
              } else if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FloatUpAnimation(
                          0.6,
                          Icon(Icons.live_tv,
                              color: Colors.grey[400], size: 60),
                        ),
                        SizedBox(height: 10),
                        FloatUpAnimation(
                          0.8,
                          Text(
                            'No Recent Streaming',
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
              } else {
                return FloatUpAnimation(
                  0.8,
                  Container(
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data.documents.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height * 0.8),
                        crossAxisCount: 2,
                        crossAxisSpacing: 2.0,
                        mainAxisSpacing: 2.0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: liveContent(
                            appId: '${snapshot.data.documents[index]["appId"]}',
                            title: '${snapshot.data.documents[index]["title"]}',
                            thumbnail:
                                '${snapshot.data.documents[index]["thumbnail"]}',
                            liveAdmin:
                                '${snapshot.data.documents[index]["broadcaster"]["username"]}',
                            adminProfile:
                                '${snapshot.data.documents[index]["broadcaster"]["profile"]["imageProfile"]}',
                            channelName:
                                '${snapshot.data.documents[index]["channelName"]}',
                            view:
                                '${snapshot.data.documents[index]["clickToView"]}',
                            pathVideo:
                                '${snapshot.data.documents[index]["pathVideo"]}',
                          ),
                        );
                      },
                    ),
                  ),
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

  Widget showUsername() {
    return Text(
      'Login by $username',
      style: TextStyle(
        color: Colors.white,
        fontSize: 8.0,
      ),
    );
  }

  Widget liveContent(
      {thumbnail,
      liveAdmin,
      adminProfile,
      channelName,
      title,
      appId,
      view,
      pathVideo}) {
    return InkWell(
      onTap: () {
        //TODO: pass old view value instead of new one
        Firestore.instance
            .collection('CurrentLive')
            .document(channelName)
            .updateData({
          "clickToView": FieldValue.increment(1),
        });
        Navigator.pushNamed(
          context,
          '/recentLivePage',
          arguments: RecentLivePage(
            title: title,
            adminProfile: adminProfile,
            liveAdmin: liveAdmin,
            channelName: channelName,
            username: username,
            appId: appId,
            view: view,
            pathVideo: pathVideo,
            role: ClientRole.Audience,
          ),
        ).then((cartData) {
          getUserCartData().then((cartData) {
            setState(() {
              _cartData = cartData;
              cartLen = _cartData.cartDetails.length;
            });
            print('cartLen: $cartLen');
          });
        });
      },
      child: Container(
        margin: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(thumbnail),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 6.0),
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.orange[400].withOpacity(0.6),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            bottomLeft: Radius.circular(5.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Recently',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 20.0,
                        padding: EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 12.0,
                            ),
                            SizedBox(width: 1.0),
                            Center(
                              child: StreamBuilder(
                                stream: FireStoreClass.getViewer(
                                    liveAdmin, channelName),
                                builder: (BuildContext context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: Text(
                                        '0',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      view,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 2.0),
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 14.0,
                          backgroundImage: NetworkImage("$adminProfile"),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          liveAdmin,
                          style: TextStyle(color: Colors.white, fontSize: 12.0),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
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
