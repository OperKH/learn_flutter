import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../../models/product.dart';
import '../../scoped-models/products.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(List<Product> products) {
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
            child: ScopedModelDescendant<ProductsModel>(
              builder:
                  (BuildContext context, Widget child, ProductsModel model) {
                return _buildProductList(model.products);
              },
            ),
          ),
        ],
      ),
    );
  }
}
