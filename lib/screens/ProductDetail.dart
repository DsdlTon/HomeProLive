import 'package:flutter/material.dart';
import '../models/Product.dart';
import '../controllers/api.dart';

class ProductDetailPage extends StatefulWidget {
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product _product;

  @override
  void initState() {
    super.initState();
    ProductService.getProductDetail(1)
        .then((product) => print('PPPP: $product'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('PRODUCT'),
        ),
      ),
    );
  }
}
