import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/models/Order.dart';
import 'package:test_live_app/screens/ItemInOrder.dart';
import '../widgets/logoutDialog.dart';

class OrderListPage extends StatefulWidget {
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  Cart _cartData = Cart();
  Order _orderData = Order();
  String username = '';
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
    return CartService.getUserCart(headers);
  }

  Future<Order> getAllOrderInDB() async {
    print('Enter getAllOrderInDB');
    final headers = {
      "access-token": _accessToken,
    };
    return OrderService.getAllOrder(headers);
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
      backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: FutureBuilder(
            future: getAllOrderInDB(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return orderPanel(snapshot);
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget orderPanel(snapshot) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        reverse: true,
        physics: BouncingScrollPhysics(),
        controller: new ScrollController(keepScrollOffset: false),
        itemCount: snapshot.data.orders.length,
        itemBuilder: (context, index) {
          return orderCard(snapshot.data.orders, index);
        },
      ),
    );
  }

  Widget orderCard(orders, index) {
    return GestureDetector(
      onTap: () {
        print('Tap order id ${orders[index].id}');
        print('order length ${orders.length}');
        print(index);
        Navigator.pushNamed(
          context,
          '/itemInOrder',
          arguments: ItemInOrder(
            orderId: orders[index].id,
            index: index,
          ),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300],
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            showOrderImage(orders[index].orderItem[0].product.image),
            showOrderDetail(orders, index),
          ],
        ),
      ),
    );
  }

  Widget showOrderImage(image) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * 0.3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget showOrderDetail(orders, index) {
    int orderNum = index + 1;
    return Container(
      margin: EdgeInsets.only(left: 12),
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Order #$orderNum',
                style: TextStyle(
                  height: 1.5,
                  color: Colors.black,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              orders[index].paymentStatus == false
                  ? Text(
                      'Payment: waiting for payment',
                      style: TextStyle(
                        height: 1.5,
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      'Payment: Completed',
                      style: TextStyle(
                        height: 1.5,
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
              // Text(
              //   'Payment Type: ${orders[index].paymentType}',
              //   style: TextStyle(
              //     height: 1.5,
              //     color: Colors.black,
              //     fontSize: 12,
              //   ),
              // ),
              Text(
                'Delivery: ${orders[index].deliveryStatus}',
                style: TextStyle(
                  height: 1.5,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
              Text(
                'data: ${orders[index].createdAt}',
                style: TextStyle(
                  height: 1.5,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
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
