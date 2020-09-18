import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String username;

  Future<void> checkAuthen() async {
    await Future.delayed(Duration(milliseconds: 1000), () {
      if (username != null) {
        Navigator.of(context).pushReplacementNamed('/homePage');
      } else {
        Navigator.of(context).pushReplacementNamed('/loginPage');
      }
    });
  }

  getUsernameInPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    return username;
  }

  @override
  void initState() {
    super.initState();
    getUsernameInPref();
    checkAuthen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bg and filter
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/home-background.png'),
            fit: BoxFit.cover,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue[800].withOpacity(0.8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              appLogo(),
              appName(),
            ],
          ),
        ),
      ),
    );
  }

  Widget appLogo() {
    return Container(
      width: 90.0,
      height: 60.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/logo.png'),
        ),
      ),
    );
  }

  Widget appName() {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'HomePro',
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
          TextSpan(
            text: ' Live',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
