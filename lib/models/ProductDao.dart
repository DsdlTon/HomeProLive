class ProductDao {
  int id;
  String sku;
  String image;
  String brand;
  String title;
  int price;
  List detailProducts;

  ProductDao({
    this.id,
    this.sku,
    this.image,
    this.brand,
    this.title,
    this.price,
    this.detailProducts,
  });

  factory ProductDao.fromJson(Map<String, dynamic> json) {
    return ProductDao(
      id: json["id"],
      sku: json["sku"],
      image: json["image"],
      brand: json["brand"],
      title: json["title"],
      price: json["price"],
      detailProducts: json["detailProducts"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      'sku': sku,
      'image': image,
      'brand': brand,
      'title': title,
      'price': price,
      'detailProducts': detailProducts,
    };
  }
}
