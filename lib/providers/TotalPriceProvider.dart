import 'package:flutter/cupertino.dart';

class TotalPriceProvider with ChangeNotifier {
  double initialPrice;
  double productPrice;

  TotalPriceProvider({
    this.initialPrice,
    this.productPrice,
  });

  addQuantity(initialPrice, productPrice) {
    print('Enter addQuantity');
    print('newTotalPrice: $initialPrice += $productPrice');
    initialPrice += productPrice;
    print('newTotalPrice: $initialPrice');
    notifyListeners();
  }

  deleteQuantity(initialPrice, productPrice) {
    print('Enter deleteQuantity');
    print('newTotalPrice: $initialPrice -= $productPrice');
    initialPrice -= productPrice;
    print('newTotalPrice: $initialPrice');
    notifyListeners();
  }
}
