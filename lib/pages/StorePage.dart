import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:test_live_app/components/Chairs.dart';
import 'package:test_live_app/components/Desks.dart';
import 'package:test_live_app/components/Electronic.dart';
import 'package:test_live_app/components/Sofa.dart';
import 'package:test_live_app/pages/CartPage.dart';
import 'package:test_live_app/providers/CategoryCardChange.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: searchBox(),
        leading: drawerMenu(),
        actions: <Widget>[
          searchButton(),
          cartButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              catelogPanel(),
              SizedBox(height: 10),
              showSelectedCatelog(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showSelectedCatelog() {
    return Container(
      width: double.infinity,
      child: Consumer<CategoryChangeProvider>(
        builder: (context, value, _) {
          Widget child;
          if (value.category == "Chairs") {
            child = Chairs();
          } else if (value.category == "Sofa") {
            child = Sofa();
          } else if (value.category == "Desks") {
            child = Desks();
          } else if (value.category == "Electronic") {
            child = Electronic();
          }
          return child;
        },
      ),
    );
  }

  Widget catelogPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Categories',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "See all",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600),
                        ),
                        WidgetSpan(
                          child: Icon(Icons.arrow_right, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              catelogCard(
                title: 'Chairs',
                image: 'assets/chair.png',
                quantity: '4512',
              ),
              catelogCard(
                title: 'Sofa',
                image: 'assets/sofa.png',
                quantity: '154',
              ),
              catelogCard(
                title: 'Desks',
                image: 'assets/desk.png',
                quantity: '794',
              ),
              catelogCard(
                title: 'Electronic',
                image: 'assets/light.png',
                quantity: '2471',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget catelogCard({title, image, quantity}) {
    return Consumer<CategoryChangeProvider>(builder: (context, value, _) {
      return GestureDetector(
        onTap: () {
          print(title);
          value.swapCategory(title);
        },
        child: AspectRatio(
          aspectRatio: 4 / 5.5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.only(right: 7, left: 2),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: value.category == title
                        ? Colors.blue[300].withOpacity(0.8)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Colors.grey[300],
                        offset: Offset(0.0, 5.0),
                      ),
                    ],
                  ),
                  height: MediaQuery.of(context).size.height / 6,
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
                      ),
                      SizedBox(height: 3),
                      Text(
                        '$quantity items',
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
    });
  }

  Widget cartButton() {
    return IconButton(
      icon: Icon(
        Icons.shopping_cart,
        color: Colors.black,
      ),
      tooltip: 'Cart',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(),
          ),
        );
      },
    );
  }

  Widget searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
            size: 20.0,
          ),
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget searchButton() {
    return IconButton(
      onPressed: () {
        print(_searchController.text.toString());
      },
      icon: Icon(
        Icons.search,
        color: Colors.black,
      ),
    );
  }

  Widget drawerMenu() {
    return IconButton(
      icon: Icon(
        Icons.dehaze,
        color: Colors.black,
      ),
      onPressed: () {
        _scaffoldKey.currentState.openDrawer();
      },
    );
  }
}
