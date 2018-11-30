import 'package:flutter/material.dart';

import './product_card.dart';
import '../../models/product.dart';

class Products extends StatelessWidget {
  final List<Product> products;

  Products(this.products);

  Widget _buildProductList() {
    if (products.length == 0) {
      return Container(
        margin: EdgeInsets.only(top: 10),
        child: Text('No produts'),
      );
    }
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) =>
          ProductCard(products[index], index),
      itemCount: products.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }
}
