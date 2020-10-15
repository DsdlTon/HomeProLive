import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/providers/TotalPriceProvider.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import '../widgets/DeleteItemConfirmationDialog.dart';
// import 'package:loader/loader.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Cart _cartData = Cart();
  int cartLen = 0;
  List cartItem = [];
  String _accessToken;
  double initialPrice = 0.0;

  bool loading = true;

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

  //same function as addProductToCart
  Future<void> changeInCartQuantity(sku, _quantity, title) async {
    print("Enter changeInCartQuantity");
    loading = true;
    final headers = {
      "access-token": _accessToken,
    };
    final body = {
      "sku": sku.toString(),
      "quantity": _quantity.toString(),
    };
    CartService.addToCart(headers, body).then((res) {
      if (res == true) {
        setState(() {
          loading = false;
        });
        print('Success');
      } else {
        setState(() {
          loading = false;
        });
        print('Failed');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAccessToken().then((accessToken) {
      getUserCartData().then((cartData) {
        setState(() {
          _cartData = cartData;
          cartItem = _cartData.cartDetails;
          cartLen = _cartData.cartDetails.length;
          loading = false;
        });
        Provider.of<TotalPriceProvider>(context, listen: false)
            .calculateInitialPrice(cartLen, cartItem);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TotalPriceProvider totalPriceProvider =
        Provider.of<TotalPriceProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(bottom: 0),
        child: Column(
          children: <Widget>[
            customAppBar(),
            Expanded(
              child: loading == true
                  ? Container(
                      color: Colors.white.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.blue[800],
                        ),
                      ),
                    )
                  : cartItem.isEmpty
                      ? nothingInCart()
                      : cartPanel(totalPriceProvider),
            ),
            checkOutButton(totalPriceProvider),
          ],
        ),
      ),
    );
  }

  Widget nothingInCart() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.77,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.remove_shopping_cart,
              color: Colors.grey[400],
              size: 60,
            ),
            Text(
              'Nothing in Cart',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ],
        ),
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

  Widget cartPanel(totalPriceProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.77,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        controller: new ScrollController(keepScrollOffset: false),
        itemCount: cartLen,
        itemBuilder: (BuildContext context, int index) {
          return cartItemCard(index, totalPriceProvider);
        },
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

  Widget cartItemCard(index, totalPriceProvider) {
    return Dismissible(
      key: ValueKey(cartItem[index].product.sku.toString()),
      background: trashBg(),
      // confirmDismiss: (direction) async {
      //   return await showDialog(
      //     context: context,
      //     builder: (BuildContext context) => DeleteItemConfirmationDialog(
      //       accessToken: _accessToken,
      //       cartItemSku: cartItem[index].product.sku.toString(),
      //       cartItem: cartItem,
      //       index: index,
      //     ),
      //   );
      // },
      onDismissed: (direction) async {
        final headers = {
          "access-token": _accessToken,
        };
        final body = {
          "sku": cartItem[index].product.sku.toString(),
        };
        await CartService.removeItemInCart(headers, body);
        setState(() {
          cartItem.removeAt(index);
          cartLen = cartItem.length;
          Provider.of<TotalPriceProvider>(context, listen: false)
              .calculateInitialPrice(cartLen, cartItem);
        });
        Fluttertoast.showToast(
          msg: "Deleted Success.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[800],
          textColor: Colors.white,
          fontSize: 13.0,
        );
      },
      direction: DismissDirection.endToStart,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
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
            showInCartDetail(index, totalPriceProvider),
          ],
        ),
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

  Widget showInCartDetail(index, totalPriceProvider) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // if Navigate and change quantity in productDetailPage. This page will not update the new Quantity data
          // because it not initialize again when pop().

          // Navigator.pushNamed(
          //   context,
          //   '/productDetailPage',
          //   arguments: ProductDetailPage(
          //     sku: cartItem[index].product.sku,
          //   ),
          // );
        },
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
                  showQuantityPanel(index, totalPriceProvider),
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
      ),
    );
  }

  Widget showQuantityPanel(index, totalPriceProvider) {
    return Container(
      child: Row(
        children: <Widget>[
          decreaseButton(index, totalPriceProvider),
          selectedQuantity(index, totalPriceProvider),
          increaseButton(index, totalPriceProvider),
        ],
      ),
    );
  }

  Widget selectedQuantity(index, totalPriceProvider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300],
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10),
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.07,
        maxWidth: MediaQuery.of(context).size.width * 0.12,
      ),
      height: MediaQuery.of(context).size.height * 0.04,
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: 15,
          color: Colors.blue[800],
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        textAlign: TextAlign.center,
        onSubmitted: (q) {
          setState(() {
            cartItem[index].quantity = int.parse(q);
          });

          String sku = cartItem[index].product.sku;
          int _quantity = cartItem[index].quantity;
          String title = cartItem[index].product.title;
          print('sku: $sku,\n_quantity: $_quantity,\ntitle: $title,');

          changeInCartQuantity(sku, _quantity, title);

          totalPriceProvider.calculateInitialPrice(cartLen, cartItem);
        },
        controller: TextEditingController()
          ..text = '${cartItem[index].quantity}',
        // onChanged: (text) {},
      ),
    );
  }

  Widget decreaseButton(index, totalPriceProvider) {
    return GestureDetector(
      onTap: () {
        if (cartItem[index].quantity > 1) {
          decreaseProcess(index, totalPriceProvider);
        }
      },
      child: decreaseIcon(index),
    );
  }

  Widget decreaseIcon(index) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1.5, color: Colors.grey[300]),
      ),
      child: Icon(
        Icons.remove,
        size: 15,
        color: cartItem[index].quantity > 1 ? Colors.black : Colors.grey[300],
      ),
    );
  }

  decreaseProcess(index, totalPriceProvider) {
    setState(() {
      cartItem[index].quantity > 1
          ? cartItem[index].quantity -= 1
          : cartItem[index].quantity = 1;

      print(cartItem[index].quantity);

      String sku = cartItem[index].product.sku;
      int _quantity = cartItem[index].quantity;
      String title = cartItem[index].product.title;

      print('sku: $sku, _quantity: $_quantity, title: $title');

      changeInCartQuantity(sku, _quantity, title);

      double productPrice = double.parse(cartItem[index].product.price);
      totalPriceProvider.deleteQuantity(
          totalPriceProvider.initialPrice, productPrice);
    });
  }

  Widget increaseButton(index, totalPriceProvider) {
    return GestureDetector(
      onTap: () {
        increaseProcess(index, totalPriceProvider);
      },
      child: increaseIcon(),
    );
  }

  Widget increaseIcon() {
    return Container(
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
    );
  }

  increaseProcess(index, totalPriceProvider) {
    setState(() {
      cartItem[index].quantity += 1;
    });

    String sku = cartItem[index].product.sku;
    int _quantity = cartItem[index].quantity;
    String title = cartItem[index].product.title;
    print('sku: $sku,\n_quantity: $_quantity,\ntitle: $title,');

    changeInCartQuantity(sku, _quantity, title);

    double productPrice = double.parse(cartItem[index].product.price);
    totalPriceProvider.addQuantity(
        totalPriceProvider.initialPrice, productPrice);
  }

  Widget showTotalPrice(totalPriceProvider) {
    return Container(
      child: ChangeNotifierProvider<TotalPriceProvider>.value(
        value: totalPriceProvider,
        child: Consumer<TotalPriceProvider>(
          builder: (context, totalPriceProvider, child) {
            return Text(
              '฿ ${totalPriceProvider.initialPrice}',
              style: TextStyle(
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget checkOutButton(totalPriceProvider) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 48,
        width: MediaQuery.of(context).size.width,
        decoration: cartItem.isEmpty
            ? BoxDecoration(
                color: Colors.grey,
              )
            : BoxDecoration(
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
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              'CHECK OUT | ',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            showTotalPrice(totalPriceProvider),
          ],
        ),
      ),
    );
  }
}
