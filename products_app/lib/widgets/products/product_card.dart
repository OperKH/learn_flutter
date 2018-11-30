import 'package:flutter/material.dart';

import './title_price_row.dart';
import './address_tag.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int index;

  ProductCard(this.product, this.index);

  Widget _buildProductBar(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          color: Colors.blue,
          onPressed: () => Navigator.pushNamed(context, '/product/$index'),
        ),
        IconButton(
          icon: Icon(Icons.favorite_border),
          color: Colors.red,
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(product.image),
          TitlePriceRow(product),
          AddressTag('Union Square, San Francisko'),
          _buildProductBar(context),
        ],
      ),
    );
  }
}
