import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/products/price_tag.dart';
import '../widgets/ui_elements/title_default.dart';

class ProductPage extends StatelessWidget {
  final Map<String, dynamic> product;

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
          title: Text(product['title']),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Image.asset(product['image']),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TitleDefault(product['title']),
                    SizedBox(width: 8),
                    PriceTag(product['price'].toString()),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Union Square, San Francisko'),
              ),
              SizedBox(height: 6),
              Text(product['description'])
            ],
          ),
        ),
      ),
    );
  }
}
