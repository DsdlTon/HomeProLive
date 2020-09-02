import 'package:flutter/material.dart';

class Chairs extends StatefulWidget {
  @override
  _ChairsState createState() => _ChairsState();
}

class _ChairsState extends State<Chairs> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            bestSeller(),
            allProduct(),
          ],
        ),
      ),
    );
  }

  Widget bestSeller() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Best Sellers',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                highlightedItemCard(
                    title: 'X-Comfort Black-White Gaming Chair',
                    image: 'assets/chair1.jpg',
                    price: '1490'),
                highlightedItemCard(
                    title: 'Dining Chair',
                    image: 'assets/chair2.jpg',
                    price: '850'),
                highlightedItemCard(
                    title: 'Camping Chair',
                    image: 'assets/chair3.jpg',
                    price: '490'),
                highlightedItemCard(
                    title: 'X-Comfort Black-Purple Gaming Chair',
                    image: 'assets/chair4.jpg',
                    price: '1490'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget allProduct() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'All Products',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            // height: 500,
            color: Colors.orange,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              controller: new ScrollController(keepScrollOffset: false),
              scrollDirection: Axis.vertical,
              childAspectRatio: (2 / 2),
              children: <Widget>[
                normalItemCard(productImage: 'assets/chair1.jpg'),
                normalItemCard(productImage: 'assets/chair1.jpg'),
                normalItemCard(productImage: 'assets/chair1.jpg'),
                normalItemCard(productImage: 'assets/chair1.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // itemCard in Best Sellers Section
  Widget highlightedItemCard({title, image, price}) {
    return GestureDetector(
      onTap: () {
        print(title);
      },
      child: AspectRatio(
        aspectRatio: 4 / 5.5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: EdgeInsets.only(right: 5, left: 4),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8.0,
                      color: Colors.grey[300],
                      offset: Offset(0.0, 5.0),
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height / 4.5,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(image),
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.only(left: 5),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 3),
                    Text(
                      '฿$price',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //itemCard in allProduct Section
  Widget normalItemCard({title, productImage, price}) {
    return GestureDetector(
      onTap: () {
        print(title);
      },
      child: Container(
        margin: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(productImage),
          ),
        ),
      ),
    );
  }
}
