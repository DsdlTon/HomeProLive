import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:test_live_app/screens/selectedAddress.dart';

class CheckOutPage extends StatefulWidget {
  final double totalPrice;

  const CheckOutPage({
    Key key,
    @required this.totalPrice,
  }) : super(key: key);
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  Cart _cartData = Cart();
  int cartLen = 0;
  List cartItem = [];
  String _accessToken;
  int deliveryCost = 30;
  double totalPayment;
  var headers;

  int _defaultLocation;

  int _keyboardVisibilitySubscriberId;
  bool _keyboardState;
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
    return CartService.getUserCart(headers);
  }

  readDefaultLocationInPref() async {
    print('read default location as index');
    final prefs = await SharedPreferences.getInstance();
    int defaultLocation = prefs.getInt('defaultLocationIndex');
    return defaultLocation;
  }

  @override
  void initState() {
    super.initState();
    _keyboardState = _keyboardVisibility.isKeyboardVisible;
    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        setState(() {
          _keyboardState = visible;
          if (_keyboardState != true) {
            setState(() {
              FocusScope.of(context).unfocus();
            });
          }
        });
      },
    );

    readDefaultLocationInPref().then((defaultLocation) {
      setState(() {
        _defaultLocation = defaultLocation;
        print('This is defaultLocation index: $_defaultLocation');
      });
    });

    getAccessToken().then((accesstoken) {
      headers = {"access-token": accesstoken};
      getUserCartData().then((cartData) {
        setState(() {
          _cartData = cartData;
          cartItem = _cartData.cartDetails;
          cartLen = _cartData.cartDetails.length;
        });
      });
    });
    totalPayment = widget.totalPrice + deliveryCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        automaticallyImplyLeading: false,
        centerTitle: true,
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
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  addressBar(),
                  boughtProduct(),
                  delivery(),
                  descriptionPanel(),
                  SizedBox(height: 10),
                  paymentMethod(),
                  paymentInDetail(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ],
              ),
            ),
            _keyboardState == false ? bottomBar() : Container(),
          ],
        ),
      ),
    );
  }

  Widget smallIoSArrow() {
    return Icon(
      Icons.arrow_forward_ios,
      color: Colors.black,
      size: 10,
    );
  }

  Widget bottomBar() {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            totalPaymentPanel(),
            confirmButton(),
          ],
        ),
      ),
    );
  }

  Widget totalPaymentPanel() {
    return Container(
      padding: EdgeInsets.only(top: 8, right: 10),
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            'Total Payment',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          Text(
            '฿$totalPayment',
            style: TextStyle(
              color: Colors.blue[800],
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget confirmButton() {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.blue[800],
        child: Center(
          child: Text(
            'Confirm',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget addressBar() {
    return GestureDetector(
      onTap: () {
        print('Tap addressBar');
        Navigator.pushReplacementNamed(
          context,
          '/selectedAddressPage',
          arguments: SelectedAddressPage(
            totalPrice: widget.totalPrice,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            addressInfo(),
            smallIoSArrow(),
          ],
        ),
      ),
    );
  }

  Widget addressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.location_on,
              size: 18,
              color: Colors.blue[800],
            ),
            SizedBox(width: 3),
            Text(
              'Delivery Address',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(21, 0, 8, 3),
          child: _defaultLocation == null
              ? Text(
                  'No default address to delivery. Please add a new one.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                )
              : defaultLocationDetail(),
        )
      ],
    );
  }

  Widget defaultLocationDetail() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      child: FutureBuilder(
        future: AddressService.getAllUserAddress(headers),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return addressPanel(snapshot, _defaultLocation);
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
    );
  }

  Widget addressPanel(snapshot, _defaultLocation) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '${snapshot.data[_defaultLocation].firstname} ${snapshot.data[_defaultLocation].lastname}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
              Text(
                ' | ${snapshot.data[_defaultLocation].phone}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '${snapshot.data[_defaultLocation].homeNo} หมู่ที่${snapshot.data[_defaultLocation].moo} ${snapshot.data[_defaultLocation].villageCondoname} ห้องเลขที่${snapshot.data[_defaultLocation].roomNo} ชั้น${snapshot.data[_defaultLocation].floor} ถนน${snapshot.data[_defaultLocation].street} ซอย ${snapshot.data[_defaultLocation].soi} เขต/อำเภอ ${snapshot.data[_defaultLocation].district} แขวง/ตำบล ${snapshot.data[_defaultLocation].subDistrict} ${snapshot.data[_defaultLocation].province}',
            style: TextStyle(color: Colors.black, fontSize: 12, height: 1),
          ),
        ],
      ),
    );
  }

  //Fix This by remove _defaultLocation and find another parameter insteat
  // Widget addressPanel(snapshot, _defaultLocation) {
  //   print('///////// $_defaultLocation');
  //   return Container(
  //     child: ListView.builder(
  //       scrollDirection: Axis.vertical,
  //       shrinkWrap: true,
  //       physics: BouncingScrollPhysics(),
  //       controller: new ScrollController(keepScrollOffset: false),
  //       itemCount: 1,
  //       itemBuilder: (context, index) {
  //         index = _defaultLocation;
  //         return addressCard(snapshot, index);
  //       },
  //     ),
  //   );
  // }

  Widget addressCard(snapshot, index) {
    return Container(
      padding: EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '${snapshot.data[index].firstname} ${snapshot.data[index].lastname}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
              Text(
                ' | ${snapshot.data[index].phone}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '${snapshot.data[index].homeNo} หมู่ที่${snapshot.data[index].moo} ${snapshot.data[index].villageCondoname} ห้องเลขที่${snapshot.data[index].roomNo} ชั้น${snapshot.data[index].floor} ถนน${snapshot.data[index].street} ซอย ${snapshot.data[index].soi} เขต/อำเภอ ${snapshot.data[index].district} แขวง/ตำบล ${snapshot.data[index].subDistrict} ${snapshot.data[index].province}',
            style: TextStyle(color: Colors.black, fontSize: 12, height: 1),
          ),
        ],
      ),
    );
  }

  Widget boughtProduct() {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        controller: new ScrollController(keepScrollOffset: false),
        itemCount: cartLen,
        itemBuilder: (BuildContext context, int index) {
          return cartItemCard(index);
        },
      ),
    );
  }

  Widget cartItemCard(index) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
          showInCartImage(index),
          showInCartDetail(index),
        ],
      ),
    );
  }

  Widget showInCartImage(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
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
                    height: 1.8,
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  cartItem[index].product.brand,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.8,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'QTY: ${cartItem[index].quantity}',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.8,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '฿${cartItem[index].product.price}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget delivery() {
    return GestureDetector(
      onTap: () {
        print('Tap delivery selection');
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.1),
          border: Border(
            top: BorderSide(width: 0.5, color: Colors.greenAccent),
            bottom: BorderSide(width: 0.5, color: Colors.greenAccent),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(bottom: 5),
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              child: Text(
                'Delivery Option',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 12,
                  color: Colors.greenAccent[400],
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Normal Delivery',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Kerry',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            ' · ฿$deliveryCost',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  smallIoSArrow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget descriptionPanel() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Description: ',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Leave a message to the seller or courier',
                  hintStyle: TextStyle(fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentMethod() {
    return GestureDetector(
      onTap: () {
        print('Tap payment method');
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.08,
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Payment Method',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text(
                    'Credit/Debit card',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  smallIoSArrow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentInDetail() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total Product Price',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
              Text(
                '฿${widget.totalPrice}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Delivery Cost',
                style: TextStyle(
                  height: 2,
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
              Text(
                '฿$deliveryCost',
                style: TextStyle(
                  height: 2,
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total Payment',
                style: TextStyle(
                  height: 1.8,
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '฿$totalPayment',
                style: TextStyle(
                  height: 1.8,
                  color: Colors.blue[800],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
