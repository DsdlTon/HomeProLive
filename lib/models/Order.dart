import 'Orders.dart';

class Order {
  String message;
  int length;
  List<Orders> orders;

  Order({this.message, this.length, this.orders});

  Order.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    length = json['length'];
    if (json['orders'] != null) {
      orders = new List<Orders>();
      json['orders'].forEach((v) {
        orders.add(new Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['length'] = this.length;
    if (this.orders != null) {
      data['orders'] = this.orders.map((v) => v.toJson()).toList();
    }
    return data;
  }
}