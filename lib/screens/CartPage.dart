import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:test_live_app/controllers/api.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Cart _cartData = Cart();

  Future<void> getUserCartData() async {
    print('ENTER GETUSERCARTDATA');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    final headers = {
      "access-token": accessToken,
    };
    CartService.getUserCart(headers).then((cartData) {
      setState(() {
        _cartData = cartData;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUserCartData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('${_cartData.cartDetails}'),
      ),
    );
  }
}
