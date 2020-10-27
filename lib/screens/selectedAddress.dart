import 'package:flutter/material.dart';

class SelectedAddressPage extends StatefulWidget {
  @override
  _SelectedAddressPageState createState() => _SelectedAddressPageState();
}

class _SelectedAddressPageState extends State<SelectedAddressPage> {
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
          'Select your Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(),
            GestureDetector(
              onTap: () {
                print('Tap add new Address');
                Navigator.pushNamed(context, '/newAddressPage');
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.08,
                margin: EdgeInsets.symmetric(vertical: 3),
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Add new Address',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    Icon(Icons.add, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
