import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../../scoped-models/main.dart';
import '../../widgets/platform/platform_progress_indicator.dart';

class Products extends StatelessWidget {
  Widget _buildProductList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content;
        if (model.products == null) {
          content = Center(
            child: PlatformProgressIndicator(),
          );
        } else if (model.products.length == 0) {
          content = Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Text('No produts'),
          );
        } else if (model.displayedProducts.length == 0) {
          content = Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Text('No favorite produts'),
          );
        } else {
          content = ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                ProductCard(model.displayedProducts[index]),
            itemCount: model.displayedProducts.length,
          );
        }
        return RefreshIndicator(
          onRefresh: model.fetchProducts,
          child: content,
        );
      },
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
