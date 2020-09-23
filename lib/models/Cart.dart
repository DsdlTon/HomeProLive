class Cart {
  final int id;
  final String username;
  final String productTitle;
  final String productSKU;
  final String productUrl;
  final int productPrice;
  final int productQuantity;

  Cart(this.username, this.productTitle, this.productSKU, this.productUrl,
      this.productPrice, this.productQuantity, this.id);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'productTitle': productTitle,
      'productSKU': productSKU,
      'productUrl': productUrl,
      'productPrice': productPrice,
      'productQuantity': productQuantity,
    };
  }
}
