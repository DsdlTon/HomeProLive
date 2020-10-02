import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:test_live_app/screens/ChatPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/screens/ProductDetailPage.dart';

class RecentForegroundLive extends StatefulWidget {
  final String title;
  final String adminProfile;
  final String liveAdmin;
  final String username;
  final String channelName;

  RecentForegroundLive(
      {this.title,
      this.channelName,
      this.adminProfile,
      this.liveAdmin,
      this.username});

  @override
  _RecentForegroundLiveState createState() => _RecentForegroundLiveState();
}

class _RecentForegroundLiveState extends State<RecentForegroundLive> {
  var commentSnapshot;
  int _quantity = 0;
  String _accessToken;

  int commentIndex = 0;
  int commentLen;
  int startLiveTime;
  int currentCommentTime;
  int lastCommentTime;
  int timer = 100;
  Timer _timer;
  List<String> allComment = [];
  List<String> pushedComment = [];
  List<String> allUsername = [];
  List<String> pushedUsername = [];

  List cart = [];
  List<String> sku = [];
  List productSnap;
  List<dynamic> product = [];

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    setState(() {
      _accessToken = accessToken;
    });
    return _accessToken;
  }

  Future<List<String>> getProductToShowInLive(channelName) async {
    await Firestore.instance
        .collection("CurrentLive")
        .document(channelName)
        .get()
        .then((snapshot) {
      productSnap = snapshot['productInLive'];
    });
    int productLen = productSnap.length;
    for (int i = 0; i < productLen; i++) {
      sku.add(productSnap[i]['sku']);
    }
    print('sku: $sku');
    print('skuType: ${sku.runtimeType}');

    return sku;
  }

  Future<int> getQuantityofItem(_accessToken, sku) async {
    final headers = {
      "access-token": _accessToken.toString(),
    };
    final body = {
      "sku": sku.toString(),
    };
    await CartService.getItemQuantity(headers, body).then((quantity) {
      print('_Quantity Before ifElse: $_quantity');
      if (_quantity == null) {
        print('ENTER IF');
        setState(() {
          _quantity = 0;
        });
      } else {
        print('ENTER ELSE');
        setState(() {
          _quantity = quantity;
        });
      }
    });
    print('_quantity In Function: $_quantity');
    return _quantity;
  }

  Future<List<dynamic>> getProductInfo(sku) async {
    await ProductService.getProduct(sku).then((res) {
      print('resWhenGet: $res');
      setState(() {
        product = res;
      });
      print('product: $product');
    });
    return product;
  }

  Future<void> addProductToCart(sku, _quantity, title) async {
    print("Enter Add to Cart");

    final headers = {
      "access-token": _accessToken,
    };
    final body = {
      "sku": sku.toString(),
      "quantity": _quantity.toString(),
    };
    print('Headers: $headers');
    print('HeadersType: ${headers.runtimeType}');
    print('body: $body');
    print('bodyType: ${body.runtimeType}');
    CartService.addToCart(headers, body).then((res) {
      print('res: $res');
      if (res == true) {
        Fluttertoast.showToast(
          msg: "Added $_quantity $title to your Cart.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue[800],
          textColor: Colors.white,
          fontSize: 13.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error! Can't get this Item to your Cart.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 13.0,
        );
      }
    });

    Navigator.of(context).pop();
  }

  Future<void> getDataFromFirebase() async {
    startLiveTime = int.parse(widget.channelName) + 2000;

    var totalComment = Firestore.instance
        .collection("CurrentLive")
        .document(widget.channelName)
        .collection("Chats")
        .orderBy("timeStamp", descending: true);
    commentSnapshot = await totalComment.getDocuments();

    //get commentLen
    commentLen = commentSnapshot.documents.length;

    //get allComment[]
    if (commentLen != 0) {
      for (int i = 0; i < commentLen; i++) {
        allComment.add(commentSnapshot.documents[i]['msg']);
      }

      //get FirstUsername
      for (int i = 0; i < commentLen; i++) {
        allUsername.add(commentSnapshot.documents[i]['username']);
      }

      Timestamp ftimestamp =
          commentSnapshot.documents[commentLen - 1]['timeStamp'];
      var fdate = ftimestamp.toDate();
      currentCommentTime = fdate.millisecondsSinceEpoch;

      Timestamp ltimestamp = commentSnapshot.documents[0]['timeStamp'];
      var ldate = ltimestamp.toDate();
      lastCommentTime = ldate.millisecondsSinceEpoch;

      commentIndex = commentLen - 1;
    } else {
      print('NO COMMENT IN THIS LIVE');
    }

    // get firstCommentTime

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

      Timestamp ctimestamp =
          commentSnapshot.documents[commentIndex]['timeStamp'];
      var cdate = ctimestamp.toDate();
      currentCommentTime = cdate.millisecondsSinceEpoch;

      String comment = commentSnapshot.documents[commentIndex]['msg'];
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
    getAccessToken();
    replayComment();
    FireStoreClass.saveViewer(
      widget.username,
      widget.liveAdmin,
      widget.channelName,
    );
    getProductToShowInLive(widget.channelName).then((sku) {
      getProductInfo(sku);
    });
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
        icon: Icon(Icons.favorite_border, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget cartButton() {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.only(left: 5),
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
              liveAdmin: widget.liveAdmin,
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
            Row(
              children: [
                chatIcon(),
                favIcon(),
                cartButton(),
              ],
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
        return StatefulBuilder(
          builder: (BuildContext context, state) {
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
                          icon:
                              Icon(Icons.close, color: Colors.white, size: 18),
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
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.black.withOpacity(0.3),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                children: <Widget>[
                                  productInFoPreview(index),
                                  productAddToCartButton(index),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showQuantitySelection({
    selectedProductSku,
    selectedProductTitle,
    selectedProductImage,
    selectedProductPrice,
    quantityInCart,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.95),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.21,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          showProductImage(selectedProductImage),
                          showProductInfo(
                            selectedProductTitle: selectedProductTitle,
                            selectedProductPrice: selectedProductPrice,
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                state(() {
                                  quantityInCart > 0
                                      ? quantityInCart -= 1
                                      : quantityInCart = 0;
                                  print(quantityInCart);
                                });
                              },
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1.5, color: Colors.grey[300]),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 15,
                                  color: quantityInCart > 0
                                      ? Colors.black
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$quantityInCart',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                state(() {
                                  quantityInCart += 1;
                                  print(quantityInCart);
                                });
                              },
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      buyNowButton(),
                      addToCartButton(selectedProductSku, quantityInCart,
                          selectedProductTitle),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget showProductImage(selectedProductImage) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.1,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.network(
          selectedProductImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget showProductInfo({selectedProductTitle, selectedProductPrice}) {
    return Container(
      constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showProductTitle(selectedProductTitle),
          showProductPrice(selectedProductPrice),
        ],
      ),
    );
  }

  Widget showProductTitle(selectedProductTitle) {
    return Text(
      selectedProductTitle,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15.0,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget showProductPrice(selectedProductPrice) {
    return Container(
      child: Text(
        '฿$selectedProductPrice / Item',
        style: TextStyle(
          color: Colors.blue[900],
          fontSize: 13.0,
        ),
      ),
    );
  }

  Widget buyNowButton() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.055,
      width: MediaQuery.of(context).size.width * 0.6,
      margin: EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          colors: [
            Colors.blue[600],
            Colors.blue[700],
            Colors.blue[700],
            Colors.blue[800],
          ],
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Center(
        child: Text(
          'Buy Now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget addToCartButton(sku, quantityInCart, title) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          print('Tap ADD To Cart');
          if (quantityInCart != 0) {
            addProductToCart(sku, quantityInCart, title);
          } else {
            Fluttertoast.showToast(
              msg: "Please add Quantity of Product.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 13.0,
            );
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.055,
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              colors: [
                Colors.yellow[700],
                Colors.yellow[700],
                Colors.yellow[800],
              ],
            ),
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Center(
            child: Text(
              'Add to Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget chatPanel() {
    return Container(
      width: MediaQuery.of(context).size.height / 2.7,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
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

  Widget productInFoPreview(index) {
    return InkWell(
      onTap: () {
        print('Tap to go to productDetailPage sku: ${product[index]["sku"]}');
        Navigator.pushNamed(
          context,
          '/productDetailPage',
          arguments: ProductDetailPage(
            sku: product[index]["sku"],
          ),
        );
      },
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.1,
            child: Image.network(
              product[index]['image'],
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.57,
                child: Text(
                  product[index]["title"],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Text(
                '฿ ' + product[index]["price"],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget productAddToCartButton(index) {
    return Expanded(
      child: Container(
        alignment: Alignment.centerRight,
        child: IconButton(
          onPressed: () {
            getQuantityofItem(
              _accessToken,
              product[index]["sku"],
            ).then((quantityInCart) {
              showQuantitySelection(
                selectedProductSku: product[index]["sku"],
                selectedProductTitle: product[index]["title"],
                selectedProductImage: product[index]["image"],
                selectedProductPrice: product[index]["price"],
                quantityInCart: quantityInCart,
              );
              print('${product[index]["sku"]} HAS: $_quantity');
            });
          },
          icon: Icon(
            Icons.add_shopping_cart,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
