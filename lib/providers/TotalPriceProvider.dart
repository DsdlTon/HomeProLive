import 'package:flutter/material.dart';

class TotalPriceProvider with ChangeNotifier {
  double initialPrice;
  List<double> productPrice = List<double>();

  TotalPriceProvider({
    this.initialPrice,
    this.productPrice,
  });

  calculateTotalPrice(cartLen, cartsnap) {
    print('Enter calculateTotalPrice');

    initialPrice = 0;
    for (int i = 0; i < cartLen; i++) {
      double priceInDouble = double.parse(cartsnap[i].product.price);
      double quantityInDouble = cartsnap[i].quantity.toDouble();
      initialPrice += (priceInDouble * quantityInDouble);
      notifyListeners();
    }
    print('initialPrice: $initialPrice');
    print('OUT calculateTotalPrice');
  }

  calculateTotalPricePerItem(cartsnap, index) {
    print('Enter calculateTotalPricePerItem');
    double priceInDouble = double.parse(cartsnap[index].product.price);
    double quantityInDouble = cartsnap[index].quantity.toDouble();
    double price = priceInDouble * quantityInDouble;
    if (productPrice.asMap().containsKey(index)) {
      productPrice.removeAt(index);
    }
    productPrice.insert(index, price);
    print('productPrice: $productPrice');
    print('Out calculateTotalPricePerItem');
    notifyListeners();
  }
}
