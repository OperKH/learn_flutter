import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/products/title_price_row.dart';
import '../widgets/products/address_tag.dart';
import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Image.asset(product.image),
              TitlePriceRow(product),
              AddressTag('Union Square, San Francisko'),
              SizedBox(height: 6),
              Text(product.description)
            ],
          ),
        ),
      ),
    );
  }
}
