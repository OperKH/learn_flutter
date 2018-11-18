import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  Products(this.products);

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(products[index]['image']),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  products[index]['title'],
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald',
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  products[index]['price'].toString(),
                  style: TextStyle(),
                ),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                padding: EdgeInsets.all(0),
                child: Text('details'),
                onPressed: () =>
                    Navigator.pushNamed(context, '/product/$index'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (products.length == 0) {
      return Container(
        margin: EdgeInsets.only(top: 10),
        child: Text('No produts'),
      );
    }
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
