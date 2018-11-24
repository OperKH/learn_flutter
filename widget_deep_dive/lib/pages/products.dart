import 'package:flutter/material.dart';

import '../widgets/products/products.dart';

class ProductsPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  ProductsPage(this.products);

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {},
              )
            ],
          ),
          ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage products'),
              onTap: () => Navigator.pushReplacementNamed(context, '/admin')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text('EasyList'),
      ),
      body: Products(products),
    );
  }
}
