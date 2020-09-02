import 'package:http/http.dart' as Http;
import 'dart:convert';

class UserService {
  static Future<List<UserDao>> getAllUser() async {
    var url = "http://10.0.2.2:3000/api/user/";
    var response = await Http.get(url);
    print('response: ${response.body}');
    List list = json.decode(response.body);
    return list.map((m) => UserDao.fromjson(m)).toList();
  }

  static Future<bool> createUserInDB(body) async {
    final response = await Http.post("http://10.0.2.2:3000/api/user/", body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> createUserInFirebase(body) async {
    final response = await Http.post("http://10.0.2.2:3000/api/user/createuser", body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> login(body) async {
    final response = await Http.post("http://10.0.2.2:3000/api/user/login", body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}

class UserDao {
  String username;
  String password;

  UserDao({this.username, this.password});

  factory UserDao.fromjson(Map<String, dynamic> json) {
    return UserDao(
      username: json["username"],
      password: json["password"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": this.username,
      "password": this.password,
    };
  }
}
