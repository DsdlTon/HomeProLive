import 'Product.dart';

class CartDetails {
  int quantity;
  Product product;

  CartDetails({this.quantity, this.product});

  CartDetails.fromJson(Map<String, dynamic> json) {
    quantity = json['quantity'];
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['quantity'] = this.quantity;
    if (this.product != null) {
      data['product'] = this.product.toJson();
    }
    return data;
  }
}