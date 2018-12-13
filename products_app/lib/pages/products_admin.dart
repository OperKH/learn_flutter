import 'package:flutter/material.dart';

import './product_edit.dart';
import './product_list.dart';

import '../widgets/ui_elements/logout_list_tile.dart';
import '../widgets/platform/platform_elevation.dart';

class ProductsAdminPage extends StatelessWidget {
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            elevation: getPlatformThemeData(context),
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('All Products'),
            onTap: () => Navigator.pushReplacementNamed(context, '/products'),
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  Widget _buildTab({
    @required Icon icon,
    @required String text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          icon,
          SizedBox(width: 8.0),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildDrawer(context),
        appBar: AppBar(
          elevation: getPlatformThemeData(context),
          title: Text('Manage Products'),
          bottom: TabBar(
            tabs: <Widget>[
              _buildTab(icon: Icon(Icons.create), text: 'Create Product'),
              _buildTab(icon: Icon(Icons.list), text: 'My Products'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ProductEditPage(),
            ProductListPage(),
          ],
        ),
      ),
    );
  }
}
