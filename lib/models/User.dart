class User {
  int id;
  String name;
  String surname;
  String email;
  String username;
  String password;
  String phone;
  String accessToken;
  String message;

  User({
    this.id,
    this.name,
    this.surname,
    this.email,
    this.username,
    this.password,
    this.phone,
    this.accessToken,
    this.message,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      surname: json["surname"],
      email: json["email"],
      username: json["username"],
      password: json["password"],
      phone: json["phone"],
      accessToken: json["accessToken"],
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "surname": this.surname,
      "email": this.email,
      "username": this.username,
      "password": this.password,
      "phone": this.phone,
      "accessToken": this.accessToken,
      "message": this.message,
    };
  }
}