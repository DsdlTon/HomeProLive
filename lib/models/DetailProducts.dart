class DetailProducts {
  int id;
  String text;
  String createdAt;
  String updatedAt;
  String productSku;

  DetailProducts(
      {this.id, this.text, this.createdAt, this.updatedAt, this.productSku});

  DetailProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    productSku = json['product_sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['product_sku'] = this.productSku;
    return data;
  }
}
