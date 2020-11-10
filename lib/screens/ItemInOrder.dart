import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/screens/ProductDetailPage.dart';

class ItemInOrder extends StatefulWidget {
  @required
  final int orderId;
  final int index;

  const ItemInOrder({Key key, this.orderId, this.index}) : super(key: key);
  @override
  _ItemInOrderState createState() => _ItemInOrderState();
}

class _ItemInOrderState extends State<ItemInOrder> {
  var headers;
  List totalPriceList = [];

  Future<String> getAccessToken() async {
    print('getAccessToken');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    return accessToken;
  }

  calculatePrice(snapshot) {
    snapshot.data.order.orderItem.forEach((element) {
      double dbPrice = double.parse(element.product.price);
      int quantity = element.quantity;
      double calculatedPrice = dbPrice * quantity;
      totalPriceList.add(calculatedPrice);
    });
  }

  @override
  void initState() {
    getAccessToken().then((accessToken) {
      setState(() {
        headers = {
          "access-token": accessToken,
        };
      });
    });
    super.initState();
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
          'Order #${widget.index + 1}',
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
            future: OrderService.getOrder(widget.orderId, headers),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                calculatePrice(snapshot);
                return itemPanel(snapshot);
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue[800],
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

  Widget itemPanel(snapshot) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      controller: new ScrollController(keepScrollOffset: false),
      itemCount: snapshot.data.order.orderItem.length,
      itemBuilder: (context, index) {
        return itemCard(snapshot.data.order.orderItem, index);
      },
    );
  }

  // item = snapshot.data.order.orderItem
  Widget itemCard(items, index) {
    return GestureDetector(
      onTap: () {
        String productSku = items[index].product.sku;
        Navigator.pushNamed(
          context,
          '/productDetailPage',
          arguments: ProductDetailPage(
            sku: productSku,
          ),
        );
      },
      child: Container(
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
            showItemsImage(items[index].product.image),
            showItemsDetail(items, index),
          ],
        ),
      ),
    );
  }

  Widget showItemsImage(image) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // item = snapshot.data.order.orderItem
  Widget showItemsDetail(items, index) {
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
                  items[index].product.title,
                  style: TextStyle(
                    height: 1.8,
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  items[index].product.brand,
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
                      'QTY: ${items[index].quantity}',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.8,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '฿${totalPriceList[index]}',
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
}
