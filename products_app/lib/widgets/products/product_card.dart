import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';

import './title_price_row.dart';
import './address_tag.dart';
import '../../models/product.dart';
import '../../scoped-models/main.dart';
import '../../widgets/platform/platform_progress_indicator.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard(this.product);

  Widget _buildProductBar(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.info),
                color: Colors.blue,
                onPressed: () async {
                  model.selectProduct(product.id);
                  await Navigator.pushNamed(context, '/product/${product.id}');
                  model.selectProduct(null);
                }),
            IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Colors.red,
              onPressed: () async {
                model.selectProduct(product.id);
                await model.toggleProductFavoriteStatus();
                model.selectProduct(null);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: product.id,
            child: CachedNetworkImage(
              imageUrl: product.image,
              height: 300.0,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: Container(
                height: 300.0,
                child: Center(
                  child: PlatformProgressIndicator(),
                ),
              ),
              errorWidget: Icon(Icons.error),
            ),
          ),
          TitlePriceRow(product),
          AddressTag(
            '${product.location.latitude}, ${product.location.longitude}',
          ),
          SizedBox(height: 6.0),
          _buildProductBar(context),
        ],
      ),
    );
  }
}
