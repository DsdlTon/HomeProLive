import 'package:flutter/cupertino.dart';

class TotalPriceProvider with ChangeNotifier {
  var initialPrice;
  var productPrice;

  TotalPriceProvider({
    this.initialPrice,
    this.productPrice,
  });

  calculateInitialPrice(cartLen, cartItem) {
    print('Enter calculateInitialPrice');
    initialPrice = 0;
    for (int i = 0; i < cartLen; i++) {
      double priceInDouble = double.parse(cartItem[i].product.price);
      double quantityInDouble = cartItem[i].quantity.toDouble();
      print('////////////////////////////////');
      print('$initialPrice = $priceInDouble * $quantityInDouble');
      print('////////////////////////////////');
      initialPrice += (priceInDouble * quantityInDouble);
      notifyListeners();
    }
  }

  addQuantity(initialPrice, productPrice) {
    print('Enter addQuantity');
    double.parse(initialPrice.toStringAsFixed(2));
    double.parse(productPrice.toStringAsFixed(2));
    this.initialPrice += productPrice;
    notifyListeners();
  }

  deleteQuantity(initialPrice, productPrice) {
    print('Enter deleteQuantity');
    double.parse(initialPrice.toStringAsFixed(2));
    double.parse(productPrice.toStringAsFixed(2));
    this.initialPrice -= productPrice;
    notifyListeners();
  }
}
