import 'Orders.dart';

class ProductInOrder {
  String message;
  Orders order;

  ProductInOrder({this.message, this.order});

  ProductInOrder.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    order = json['order'] != null ? new Orders.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.order != null) {
      data['order'] = this.order.toJson();
    }
    return data;
  }
}