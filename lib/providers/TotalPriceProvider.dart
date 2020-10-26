import 'package:flutter/cupertino.dart';

class TotalPriceProvider with ChangeNotifier {
  var initialPrice;
  List<double> productPrice = List<double>();

  TotalPriceProvider({
    this.initialPrice,
    this.productPrice,
  });

  calculateTotalPrice(cartLen, cartItem) {
    print('Enter calculateTotalPrice');
    initialPrice = 0;
    for (int i = 0; i < cartLen; i++) {
      double priceInDouble = double.parse(cartItem[i].product.price);
      double quantityInDouble = cartItem[i].quantity.toDouble();
      // print('//////////////////////');
      // print('$initialPrice += ($priceInDouble * $quantityInDouble)');
      // print('//////////////////////');
      initialPrice += (priceInDouble * quantityInDouble);
      notifyListeners();
    }
    print('OUT calculateTotalPrice');
  }

  calculateTotalPricePerItem(cartItem, index) {
    print('Enter calculateTotalPricePerItem');
    double priceInDouble = double.parse(cartItem[index].product.price);
    double quantityInDouble = cartItem[index].quantity.toDouble();
    // print('//////////////////////');
    // print('i = $index \nprice = $priceInDouble \nquantity = $quantityInDouble');
    // print('//////////////////////');
    double price = priceInDouble * quantityInDouble;
    if (productPrice.asMap().containsKey(index)) {
      productPrice.removeAt(index);
    }
    productPrice.insert(index, price);
    print(productPrice);
    notifyListeners();
  }
}
