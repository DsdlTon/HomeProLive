class Product {
  String sku;
  String brand;
  String title;
  String price;
  String image;

  Product({this.sku, this.brand, this.title, this.price, this.image});

  Product.fromJson(Map<String, dynamic> json) {
    sku = json['sku'];
    brand = json['brand'];
    title = json['title'];
    price = json['price'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sku'] = this.sku;
    data['brand'] = this.brand;
    data['title'] = this.title;
    data['price'] = this.price;
    data['image'] = this.image;
    return data;
  }
}
