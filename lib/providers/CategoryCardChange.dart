import 'package:flutter/material.dart';

class CategoryChangeProvider with ChangeNotifier {
  String _category = "Chairs";

  String get category => _category;

  void swapCategory(String value) {
    _category = value;
    notifyListeners();
  }
}
