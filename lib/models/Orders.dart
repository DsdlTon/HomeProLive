import 'OrderItem.dart';

class Orders {
  int id;
  bool paymentStatus;
  String deliveryStatus;
  String paymentType;
  String createdAt;
  String updatedAt;
  int userId;
  int addressId;
  List<OrderItem> orderItem;

  Orders(
      {this.id,
      this.paymentStatus,
      this.deliveryStatus,
      this.paymentType,
      this.createdAt,
      this.updatedAt,
      this.userId,
      this.addressId,
      this.orderItem});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentStatus = json['paymentStatus'];
    deliveryStatus = json['deliveryStatus'];
    paymentType = json['paymentType'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['user_id'];
    addressId = json['address_id'];
    if (json['orderItem'] != null) {
      orderItem = new List<OrderItem>();
      json['orderItem'].forEach((v) {
        orderItem.add(new OrderItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['paymentStatus'] = this.paymentStatus;
    data['deliveryStatus'] = this.deliveryStatus;
    data['paymentType'] = this.paymentType;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['user_id'] = this.userId;
    data['address_id'] = this.addressId;
    if (this.orderItem != null) {
      data['orderItem'] = this.orderItem.map((v) => v.toJson()).toList();
    }
    return data;
  }
}