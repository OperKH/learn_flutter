import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/products/title_price_row.dart';
import '../widgets/products/address_tag.dart';
import '../models/product.dart';
import '../scoped-models/main.dart';

class ProductPage extends StatelessWidget {
  final int productIndex;

  ProductPage(this.productIndex);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          final Product product = model.products[productIndex];
          return Scaffold(
            appBar: AppBar(
              title: Text(product.title),
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: product.image,
                    height: 300.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      height: 300.0,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: Icon(Icons.error),
                  ),
                  TitlePriceRow(product),
                  AddressTag('Union Square, San Francisko'),
                  SizedBox(height: 6),
                  Text(product.description)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
