class Product {
  String sku;
  String image;
  String brand;
  String title;
  String price;
  String createdAt;
  String updatedAt;

  Product(
      {this.sku,
      this.image,
      this.brand,
      this.title,
      this.price,
      this.createdAt,
      this.updatedAt});

  Product.fromJson(Map<String, dynamic> json) {
    sku = json['sku'];
    image = json['image'];
    brand = json['brand'];
    title = json['title'];
    price = json['price'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
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
    return data;
  }
}