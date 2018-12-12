import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/products/title_price_row.dart';
import '../widgets/products/address_tag.dart';
import '../widgets/products/product_fab.dart';
import '../models/product.dart';
import '../scoped-models/main.dart';

class ProductPage extends StatelessWidget {
  final String productId;

  ProductPage(this.productId);

  _buildMap(Product product) {
    final position =
        LatLng(product.location.latitude, product.location.longitude);
    return SizedBox(
      height: 300.0,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          controller.addMarker(MarkerOptions(
            position: position,
          ));
        },
        options: GoogleMapOptions(
          cameraPosition: CameraPosition(
            target: position,
            zoom: 17.0,
          ),
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          final Product product =
              model.products.firstWhere((product) => product.id == productId);
          return Scaffold(
            floatingActionButton: ProductFab(product),
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 256.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(product.title),
                    background: Hero(
                      tag: product.id,
                      child: CachedNetworkImage(
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
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    TitlePriceRow(product),
                    Center(
                      child: Text(
                        product.description,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 6.0),
                    _buildMap(product),
                    SizedBox(height: 6.0),
                    Center(
                      child: AddressTag(
                        '${product.location.latitude}, ${product.location.longitude}',
                      ),
                    ),
                    SizedBox(height: 6.0),
                  ]),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
