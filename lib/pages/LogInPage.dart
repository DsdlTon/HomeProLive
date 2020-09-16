import 'package:flutter/material.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/pages/ForgotPassword.dart';
import 'package:test_live_app/pages/HomePage.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username;
  String password;
  String email;

  UserDao _user;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('accessToken', _user.accessToken);
    prefs.setString('username', _user.username);
  }

  void _validateInputs() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      print('username: $username');
      print('password: $password');
      // checkAuthen();

      final body = {
        "username": username,
        "password": password,
      };

      UserService.login(body).then((user) {
        setState(() {
          _user = user;
          saveUserData();
        });

        print('/////// THIS IS accessToken: $_user');

        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext context) => HomePage());
        Navigator.of(context).pushAndRemoveUntil(
            materialPageRoute, (Route<dynamic> route) => false);
      });
    }
  }

  // Future<void> checkAuthen() async {
  //   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   await firebaseAuth
  //       .signInWithEmailAndPassword(email: email, password: password)
  //       .then((response) {
  //     print('Authen Success');
  //     MaterialPageRoute materialPageRoute =
  //         MaterialPageRoute(builder: (BuildContext context) => HomePage());
  //     Navigator.of(context).pushAndRemoveUntil(
  //         materialPageRoute, (Route<dynamic> route) => false);
  //   }).catchError((response) {
  //     String title = response.code;
  //     String message = response.message;
  //     loginAlert(title, message);
  //   });
  // }

  // void loginAlert(String title, String message) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: ListTile(
  //             leading: Icon(
  //               Icons.add_alert,
  //               color: Colors.red,
  //               size: 20.0,
  //             ),
  //             title: Text(
  //               title,
  //               style: TextStyle(color: Colors.red, fontSize: 10.0),
  //             ),
  //           ),
  //           content: Text(
  //             message,
  //             style: TextStyle(color: Colors.red, fontSize: 10.0),
  //           ),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/home-background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[800].withOpacity(0.8),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.width / 1.8,
                  margin: EdgeInsets.only(top: 50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      appLogo(),
                      appName(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // fullTextFormField(
                        //   label: 'Email',
                        //   hint: 'Your email',
                        //   keyboardType: TextInputType.emailAddress,
                        //   obscureText: false,
                        //   onSaved: (String value) {
                        //     email = value.trim();
                        //   },
                        //   validator: _emailValidator,
                        // ),
                        fullTextFormField(
                          label: 'Username',
                          hint: 'Your Username',
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          onSaved: (String value) {
                            username = value.trim();
                          },
                          validator: _usernameValidator,
                        ),
                        fullTextFormField(
                          label: 'Password',
                          hint: 'Your Password',
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          onSaved: (String value) {
                            password = value.trim();
                          },
                          validator: _passwordValidator,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: loginButtonTranparent(
                        text: 'Login',
                        page: HomePage(),
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.symmetric(horizontal: -10.0),
                      child: Text(
                        'Forgot your Password?',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
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

  Widget fullTextFormField(
      {label, hint, keyboardType, onSaved, obscureText, validator}) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      // height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          width: 1.0,
          color: Colors.white,
        ),
      ),
      child: TextFormField(
        style: TextStyle(color: Colors.grey[300]),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onSaved,
      ),
    );
  }

  Widget loginButtonTranparent({text, page}) {
    return InkWell(
      onTap: () {
        _validateInputs();
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.3,
        height: 45.0,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(width: 1.0, color: Colors.white),
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

  // String _emailValidator(String value) {
  //   if (value.isEmpty) {
  //     return "Please Enter your Email Address";
  //   }
  //   String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
  //       "\\@" +
  //       "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
  //       "(" +
  //       "\\." +
  //       "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
  //       ")+";
  //   RegExp regExp = new RegExp(p);

  //   if (regExp.hasMatch(value)) {
  //     return null;
  //   }
  //   return 'Email is not valid';
  // }

  String _usernameValidator(String value) {
    if (value.isEmpty) {
      return "Please Enter Your Username";
    } else {
      return null;
    }
  }

  String _passwordValidator(String value) {
    if (value.isEmpty) {
      return "Please Enter Your Password";
    } else {
      return null;
    }
  }
}
