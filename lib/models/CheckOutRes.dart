import 'Product.dart';

class CheckOutRes {
  String message;
  Product product;

  CheckOutRes({this.message, this.product});

  CheckOutRes.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.product != null) {
      data['product'] = this.product.toJson();
    }
    return data;
  }
}
