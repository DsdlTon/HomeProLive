import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/controllers/firebaseDB.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:test_live_app/screens/ChatPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/screens/ProductDetailPage.dart';

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

  List<String> sku = [];
  List productSnap;
  List<dynamic> product = [];
  String _accessToken;

  Cart _cartData = Cart();
  int cartLen = 0;
  int _quantity = 0;

  KeyboardVisibilityNotification _keyboardVisibility =
      KeyboardVisibilityNotification();

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

  Future<List<String>> getProductToShowInLive(channelName) async {
    await Firestore.instance
        .collection("CurrentLive")
        .document(channelName)
        .collection("ProductInLive")
        .getDocuments()
        .then((snapshot) {
      productSnap = snapshot.documents;
    });

    //TODO: MOCKED DATA, DeleteLater
    // sku.add('1');
    // sku.add('2');
    // sku.add('3');
    productSnap.forEach((product) {
      sku.add(product["sku"]);
    });
    print('///////skuList: $sku');
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

  Future<List<dynamic>> getProductInfo([sku]) async {
    await ProductService.getProduct(sku).then((res) {
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
    print('body: $body');
    await CartService.addToCart(headers, body).then((res) {
      print('res: $res');
      if (res == true) {
        getUserCartData().then((cartData) {
          setState(() {
            _cartData = cartData;
            cartLen = _cartData.cartDetails.length;
          });
          print('cartLen: $cartLen');
        });
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

  @protected
  void initState() {
    super.initState();
    getAccessToken().then((accessToken) {
      getUserCartData().then((cartData) {
        setState(() {
          _cartData = cartData;
          cartLen = _cartData.cartDetails.length;
        });
        print('cartLen: $cartLen');
      });
    });
    getProductToShowInLive(widget.channelName).then((sku) {
      getProductInfo(sku);
    });
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
    sku.clear();
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
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
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(0.0),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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
    return Stack(
      children: [
        Container(
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
        ),
        cartLen != 0
            ? Positioned(
                top: 0,
                right: 3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text(
                      '$cartLen',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
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
          Navigator.pushReplacementNamed(
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
                        physics: BouncingScrollPhysics(),
                        itemCount: product.length,
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
    index,
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
                                  print('quantityInCart: $quantityInCart');
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
                                  if (quantityInCart <
                                      product[index]['quantity']) {
                                    quantityInCart += 1;
                                  }
                                  print(
                                      'productQuantity: ${product[index]['quantity']}');
                                  print('quantityInCart: $quantityInCart');
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
                                  color: quantityInCart ==
                                          product[index]['quantity']
                                      ? Colors.grey[300]
                                      : Colors.black,
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
                      buyNowButton(selectedProductSku, quantityInCart,
                          selectedProductTitle),
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

  Widget buyNowButton(sku, quantityInCart, title) {
    return GestureDetector(
      onTap: () {
        if (quantityInCart != 0) {
          addProductToCart(sku, quantityInCart, title)
              .then((value) => Navigator.pushNamed(context, '/cartPage'));
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
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                return RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: '${snapshot.data.documents[index]["username"]}: ',
                        style: TextStyle(
                          color:
                              snapshot.data.documents[index]["role"] == "admin"
                                  ? Colors.yellow[700]
                                  : Colors.blue[800],
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
        width: MediaQuery.of(context).size.width / 2.1,
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
          backgroundImage: NetworkImage("${widget.adminProfile}"),
          backgroundColor: Colors.transparent,
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
                'QTY: ${product[index]['quantity']}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  height: 1.5,
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
            if (product[index]['quantity'] != 0) {
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
                  index: index,
                );
                print('${product[index]["sku"]} HAS: $_quantity');
              });
            }
          },
          icon: Icon(
            Icons.add_shopping_cart,
            color: product[index]['quantity'] != 0
                ? Colors.white
                : Colors.grey[800],
            size: 20,
          ),
        ),
      ),
    );
  }
}
