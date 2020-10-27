import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:test_live_app/controllers/api.dart';
import '../widgets/logoutDialog.dart';

class OrderListPage extends StatefulWidget {
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
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
        leading: signOutButton(),
        title: Text(
          'Order',
          style: TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          cartButton(),
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
