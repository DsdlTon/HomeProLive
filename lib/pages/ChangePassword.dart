
import 'package:flutter/material.dart';
import 'package:test_live_app/pages/LogInPage.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String newPassword;
  String confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 60.0),
                child: Column(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 60.0, bottom: 50.0),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // fullTextFormField(
                              //     label: 'Old Password',
                              //     hint: 'Your Old Password',
                              //     keyboardType: TextInputType.text,
                              //     obscureText: true,
                              //     onSaved: (String value) {
                              //       oldPassword = value;
                              //     },
                              //     validator: _oldPasswordValidator),
                              fullTextFormField(
                                  label: 'New Password',
                                  hint: 'Your New Password',
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  onSaved: (String value) {
                                    newPassword = value;
                                  },
                                  validator: _newPasswordValidator),
                              fullTextFormField(
                                  label: 'Confirm New Password',
                                  hint: 'Confirm Your New Password',
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  onSaved: (String value) {
                                    confirmPassword = value;
                                  },
                                  validator: _confirmPasswordValidator),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            child: changePasswordButtonTranparent(
                              text: 'Submit',
                              page: LoginPage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        style: TextStyle(color: Colors.white),
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

  void _validateInputs() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      print(newPassword);
      // _changePassword(newPassword);
    }
  }

  // void _changePassword(String newPassword) async {
  //   FirebaseUser user = await FirebaseAuth.instance.currentUser();

  //   user.updatePassword(newPassword).then((_) {
  //     print("Succesfull changed password to $newPassword");
  //   }).catchError((error) {
  //     print("Password can't be changed" + error.toString());
  //   });
  // }

  Widget changePasswordButtonTranparent({text, page}) {
    return InkWell(
      onTap: () {
        _validateInputs();

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

  // check if password is existed in system
  // Future<bool> checkPassword() async {}

  String _newPasswordValidator(String value) {
    if (value.isEmpty) {
      return "Please Enter your new Password";
    } else {
      //check if password is same as original password.

      return null;
    }
  }

  String _confirmPasswordValidator(String value) {
    if (value.isEmpty) {
      return "Please Confirm Your New Password";
    } else if (confirmPassword != newPassword) {
      return "Please Enter Same Password as Above";
    } else {
      return null;
    }
  }
}
