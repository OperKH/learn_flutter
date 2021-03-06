import 'package:flutter/material.dart';

import './price_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/product.dart';

class TitlePriceRow extends StatelessWidget {
  final Product product;

  TitlePriceRow(this.product);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: TitleDefault(product.title),
          ),
          SizedBox(width: 8),
          PriceTag(product.price.toString()),
        ],
      ),
    );
  }
}
