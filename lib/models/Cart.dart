
import 'CartDetails.dart';

class Cart {
  int userId;
  List<CartDetails> cartDetails;

  Cart({this.userId, this.cartDetails});

  Cart.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    if (json['cartDetails'] != null) {
      cartDetails = new List<CartDetails>();
      json['cartDetails'].forEach((v) {
        cartDetails.add(new CartDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    if (this.cartDetails != null) {
      data['cartDetails'] = this.cartDetails.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
