import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:test_live_app/screens/ChatPage.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

class ForegroundLive extends StatefulWidget {
  final String title;
  final String adminProfile;
  final String liveAdmin;
  final String username;
  final String channelName;

  ForegroundLive(
      {this.title,
      this.channelName,
      this.adminProfile,
      this.liveAdmin,
      this.username});

  @override
  _ForegroundLiveState createState() => _ForegroundLiveState();
}

class _ForegroundLiveState extends State<ForegroundLive> {
  TextEditingController chatController = TextEditingController();
  String chatText;
  FocusNode focusNode;
  int _keyboardVisibilitySubscriberId;
  bool _keyboardState;
  List product;
  List cart = [];
  var token;

  KeyboardVisibilityNotification _keyboardVisibility =
      KeyboardVisibilityNotification();


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

  void addToBasket(product) {
    if (!cart.contains(product["title"])) {
      print('CONTAIN: ${cart.contains(product)}');
      setState(() {
        cart.add(product["title"]);
      });
      print('CART: $cart');
      Fluttertoast.showToast(
        msg: "Added ${product["title"]} to your Cart.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue[800],
        textColor: Colors.white,
        fontSize: 13.0,
      );
    } else if (cart.contains(product["title"])) {
      Fluttertoast.showToast(
        msg: "This Item is Already in your Cart.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 13.0,
      );
    }
  }

  @protected
  void initState() {
    super.initState();
    FireStoreClass.saveViewer(
      widget.username,
      widget.liveAdmin,
      widget.channelName,
    );

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
            // Colors.black.withOpacity(0.4),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.2),
      ),
      child: IconButton(
        icon: Icon(Icons.favorite_border, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget cartButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.2),
      ),
      child: IconButton(
        icon: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        tooltip: 'Cart',
        onPressed: () {
          Navigator.of(context).pushNamed('/cartPage');
        },
      ),
    );
  }

  Widget chatIcon({icon, onPressed}) {
    return Container(
      width: 40,
      height: 40,
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
              liveAdmin: widget.liveAdmin,
              isFromPage: 'foreground',
            ),
          );
        },
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  chatIcon(),
                  cartButton(),
                  favIcon(),
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/productDetailPage');
                        },
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
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                            onPressed: () {
                                              addToBasket(product[index]);
                                              Fluttertoast.showToast(
                                                msg:
                                                    "Added ${product[index]['title']} to your Cart.",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor:
                                                    Colors.blue[800],
                                                textColor: Colors.white,
                                                fontSize: 13.0,
                                              );
                                            },
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
      child: StreamBuilder(
        stream: FireStoreClass.getChat(widget.channelName),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              reverse: true,
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                return RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: '${snapshot.data.documents[index]["username"]}: ',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: snapshot.data.documents[index]["msg"],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
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
        width: MediaQuery.of(context).size.width / 2,
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
          backgroundImage: AssetImage(widget.adminProfile),
          backgroundColor: Colors.blue[800],
        ),
        SizedBox(width: 5.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.liveAdmin,
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
                        widget.liveAdmin, widget.channelName),
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
