import 'Product.dart';

class OrderItem {
  int id;
  int quantity;
  String createdAt;
  String updatedAt;
  String productSku;
  int orderId;
  int userId;
  Product product;

  OrderItem(
      {this.id,
      this.quantity,
      this.createdAt,
      this.updatedAt,
      this.productSku,
      this.orderId,
      this.userId,
      this.product});

  OrderItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    quantity = json['quantity'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    productSku = json['product_sku'];
    orderId = json['order_id'];
    userId = json['user_id'];
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['quantity'] = this.quantity;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['product_sku'] = this.productSku;
    data['order_id'] = this.orderId;
    data['user_id'] = this.userId;
    if (this.product != null) {
      data['product'] = this.product.toJson();
    }
    return data;
  }
}
