import 'package:flutter/material.dart';
import 'package:test_live_app/controllers/notification.dart';
import 'package:test_live_app/screens/ListLivePage.dart';
import 'package:test_live_app/screens/ListRecentlyLivePage.dart';

import 'package:test_live_app/screens/allChatPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int id;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationController.instance.subscribeWhenAppLaunch();
    NotificationController.instance.initLocalNotification();
  }

  final List<Widget> _pageOptions = <Widget>[
    ListLivePage(),
    ListRecentlyLivePage(),
    AllChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: MediaQuery.of(context).size.height / 13.1,
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.live_tv,
                size: 20,
              ),
              title: Text(
                'HomePro Live',
                style: TextStyle(
                  fontSize: 10.0,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.history,
                size: 20,
              ),
              title: Text(
                'Recently Live',
                style: TextStyle(
                  fontSize: 10.0,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(
                    Icons.chat_bubble,
                    size: 20,
                  ),
                  // Positioned(
                  //   right: 0,
                  //   child: Container(
                  //     height: 10,
                  //     width: 10,
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.red,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              title: Text(
                'Chat',
                style: TextStyle(
                  fontSize: 10.0,
                ),
              ),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}