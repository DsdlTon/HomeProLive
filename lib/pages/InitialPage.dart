import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:test_live_app/pages/LogInPage.dart';
import 'package:test_live_app/pages/Register.dart';
import 'package:test_live_app/services/api.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    UserService.getAllUser();
    // checkStatus();
  }

  // Future<void> checkStatus() async {
  //   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   FirebaseUser firebaseUser = await firebaseAuth.currentUser();
  //   if (firebaseUser != null) {
  //     MaterialPageRoute materialPageRoute =
  //         MaterialPageRoute(builder: (BuildContext context) => HomePage());
  //     Navigator.of(context).pushAndRemoveUntil(
  //         materialPageRoute, (Route<dynamic> route) => false);
  //   }
  // }

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
          //Text Section
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //show logo and App name
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    appLogo(),
                    appName(),
                  ],
                ),
              ),
              //login, Signin Btn
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    customRoundedButtonTranparent(
                      text: 'Login',
                      page: LoginPage(),
                    ),
                    SizedBox(height: 10.0),
                    customRoundedButton(
                      text: 'Register',
                      page: RegisterPage(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget customRoundedButtonTranparent({text, page}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.3,
        height: 45.0,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 1.0,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget customRoundedButton({text, page}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.3,
        height: 45.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 15.0,
            ),
          ),
        ),
      ),
    );
  }
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
