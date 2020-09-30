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
  int cartLen = 0;
  List cartItem = [];
  String _accessToken;
  int totalPrice = 0;

  int calculateTotalPrice() {
    return totalPrice;
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    setState(() {
      _accessToken = accessToken;
    });
    return _accessToken;
  }

  Future<void> getUserCartData() async {
    print('ENTER GETUSERCARTDATA');
    final headers = {
      "access-token": _accessToken,
    };
    CartService.getUserCart(headers).then((cartData) {
      setState(() {
        _cartData = cartData;
        cartItem = _cartData.cartDetails;
        cartLen = _cartData.cartDetails.length;
        print('_cartData: $_cartData');
        print(cartLen);
      });
    });
  }

  //same function as addProductToCart
  Future<void> changeInCartQuantity(sku, _quantity, title) async {
    print("Enter Change Quantity in Cart");
    final headers = {
      "access-token": _accessToken,
    };
    final body = {
      "sku": sku.toString(),
      "quantity": _quantity.toString(),
    };
    CartService.addToCart(headers, body).then((res) {
      if (res == true) {
        print('Success');
      } else {
        print('Failed');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAccessToken().then((accessToken) {
      getUserCartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          customAppBar(),
          cartPanel(),
          showTotalPrice(),
          checkOutButton(),
        ],
      ),
    );
  }

  Widget customAppBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.07,
      margin: EdgeInsets.fromLTRB(10, 40, 10, 0),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Center(
            child: Text(
              'Cart',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget cartPanel() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        controller: new ScrollController(keepScrollOffset: false),
        itemCount: cartLen,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.2,
            margin: EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300],
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                showInCartImage(index),
                showInCartDetail(index),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget showInCartImage(index) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * 0.3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          cartItem[index].product.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget showInCartDetail(index) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 12),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  cartItem[index].product.title,
                  style: TextStyle(
                    height: 1.5,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  cartItem[index].product.brand,
                  style: TextStyle(
                    height: 1.5,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                showQuantityPanel(index),
                SizedBox(width: 10),
                Text(
                  '฿${cartItem[index].product.price}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showQuantityPanel(index) {
    return Container(
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                cartItem[index].quantity > 0
                    ? cartItem[index].quantity -= 1
                    : cartItem[index].quantity = 0;

                print(cartItem[index].quantity);
                String sku = cartItem[index].product.sku;
                int _quantity = cartItem[index].quantity;
                String title = cartItem[index].product.title;
                print('sku: $sku, _quantity: $_quantity, title: $title');
                changeInCartQuantity(sku, _quantity, title);
              });
            },
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1.5, color: Colors.grey[300]),
              ),
              child: Icon(
                Icons.remove,
                size: 15,
                color: cartItem[index].quantity > 0
                    ? Colors.black
                    : Colors.grey[300],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${cartItem[index].quantity}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                cartItem[index].quantity += 1;
                print(cartItem[index].quantity);
                String sku = cartItem[index].product.sku;
                int _quantity = cartItem[index].quantity;
                String title = cartItem[index].product.title;
                print('sku: $sku, _quantity: $_quantity, title: $title');
                changeInCartQuantity(sku, _quantity, title);
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
    );
  }

  Widget showTotalPrice() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              'TOTAL',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 15),
            Text(
              '฿455213',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkOutButton() {
    return ButtonTheme(
      minWidth: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.075,
      child: RaisedButton(
        color: Colors.blue[800],
        onPressed: () {},
        child: Text(
          "Check Out",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
