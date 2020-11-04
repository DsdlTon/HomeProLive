import 'DetailProducts.dart';

class Product {
  String sku;
  String image;
  String brand;
  String title;
  String price;
  String createdAt;
  String updatedAt;
  int quantity;
  List<DetailProducts> detailProducts;

  Product(
      {this.sku,
      this.image,
      this.brand,
      this.title,
      this.price,
      this.createdAt,
      this.updatedAt,
      this.quantity,
      this.detailProducts});

  Product.fromJson(Map<String, dynamic> json) {
    sku = json['sku'];
    image = json['image'];
    brand = json['brand'];
    title = json['title'];
    price = json['price'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    quantity = json['quantity'];
    if (json['detailProducts'] != null) {
      detailProducts = new List<DetailProducts>();
      json['detailProducts'].forEach((v) {
        detailProducts.add(new DetailProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sku'] = this.sku;
    data['image'] = this.image;
    data['brand'] = this.brand;
    data['title'] = this.title;
    data['price'] = this.price;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['quantity'] = this.quantity;
    if (this.detailProducts != null) {
      data['detailProducts'] =
          this.detailProducts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}