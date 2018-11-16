import 'package:flutter/material.dart';

import './pages/product.dart';

class Products extends StatelessWidget {
  final List<Map<String, String>> products;
  final Function deleteProduct;

  Products(this.products, {this.deleteProduct});

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(products[index]['image']),
          Text(products[index]['title']),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Text('details'),
                  onPressed: () => Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ProductPage(
                                products[index]['title'],
                                products[index]['image'],
                              ),
                        ),
                      ).then((bool isDelete) {
                        if (isDelete) {
                          deleteProduct(index);
                        }
                      })),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (products.length == 0) return Text('No produts');
    return ListView.builder(
      itemBuilder: _buildProductItem,
      itemCount: products.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductList();
  }
}
