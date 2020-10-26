import 'package:flutter/material.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';
import '../widgets/RegisterSuccessDialog.dart';
import '../widgets/RegisterFailedDialog.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String name;
  String surname;
  String username;
  String password;
  String confirmPassword;
  String email;
  String phone;

  User _user;

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
      print('name: $name');
      print('surname: $surname');
      print('username: $username');
      print('password: $password');
      print('confirmPassword: $confirmPassword');
      print('email: $email');
      print('phone: $phone');

      final body = {
        "name": name,
        "lastname": surname,
        "username": username,
        "password": password,
        "email": email,
        "phone": phone,
      };
      UserService.createUserInDB(body).then(
        (user) {
          print('Enter createUserInDB Method');
          print('Message: $user');
          print('Message: ${user.runtimeType}');
          if (user == 200) {
            print('Add User Info in DB Success!!');
            loginProcess(body);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RegisterSuccessDialog(),
            );
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RegisterFailedDialog(user: user),
            );
          }
        },
      );
    }
  }

  void loginProcess(body) {
    UserService.login(body).then((response) {
      //login success
      if (response.message == "success") {
        setState(() {
          _user = response;
          saveUserData();
        });
      } else {
        //login failed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(response.message),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              showLogo(),
              SizedBox(height: 40.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        halfTextFormField(
                          label: 'Name',
                          hint: 'Your name',
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          onSaved: (String value) {
                            name = value.trim();
                          },
                          validator: _nameValidator,
                        ),
                        halfTextFormField(
                          label: 'Surname',
                          hint: 'Your surname',
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          onSaved: (String value) {
                            surname = value.trim();
                          },
                          validator: _surnameValidator,
                        ),
                      ],
                    ),
                    fullTextFormField(
                      label: 'Email',
                      hint: 'Enter Your Email',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      onSaved: (String value) {
                        email = value.trim();
                      },
                      validator: _emailValidator,
                    ),
                    fullTextFormField(
                      label: 'Username',
                      hint: 'Enter Your Username',
                      keyboardType: TextInputType.text,
                      obscureText: false,
                      onSaved: (String value) {
                        username = value.trim();
                      },
                      validator: _usernameValidator,
                    ),
                    fullTextFormField(
                      label: 'Password',
                      hint: 'Enter Your Password',
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      onSaved: (String value) {
                        password = value.trim();
                      },
                      validator: _passwordValidator,
                    ),
                    fullTextFormField(
                      label: 'Confirm Password',
                      hint: 'Confirm Your Password',
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      onSaved: (String value) {
                        confirmPassword = value.trim();
                      },
                      validator: _confirmPasswordValidator,
                    ),
                    fullTextFormField(
                      label: 'Phone Number',
                      hint: 'Enter Your Phone Number',
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      onSaved: (String value) {
                        phone = value.trim();
                      },
                      validator: _phoneValidator,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: RaisedButton(
                  color: Colors.blue[800],
                  onPressed: _validateInputs,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showLogo() {
    return Center(
      child: Container(
        child: CircleAvatar(
          radius: 40.0,
          backgroundColor: Colors.blue[800],
          child: Container(
            width: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ('assets/logo.png'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Form Widget Section
  Widget halfTextFormField(
      {label, hint, keyboardType, onSaved, obscureText, validator}) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width / 2.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          width: 1.0,
          color: Colors.blue[800],
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[800]),
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

  Widget fullTextFormField(
      {label, hint, keyboardType, onSaved, obscureText, validator}) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          width: 1.0,
          color: Colors.blue[800],
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[800]),
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

  //Validateor Section
  String _nameValidator(String value) {
    if (value.isEmpty) {
      return "Enter Your Name";
    } else {
      return null;
    }
  }

  String _surnameValidator(String value) {
    if (value.isEmpty) {
      return "Enter Your Surname";
    } else {
      return null;
    }
  }

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

  String _confirmPasswordValidator(String value) {
    if (value.isEmpty) {
      return "Please Confirm Your Password";
    } else if (confirmPassword != password) {
      return "Please Enter Same Password as Above";
    } else {
      return null;
    }
  }

  String _emailValidator(String value) {
    if (value.isEmpty) {
      return "Please Enter your Email Address";
    }
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      return null;
    }
    return 'Email is not valid';
  }

  String _phoneValidator(String value) {
    if (value.isEmpty) {
      return "Please Enter Your Phone Number";
    } else if (value.length != 10) {
      return "Please Enter valid Phone Number";
    } else {
      return null;
    }
  }
}
