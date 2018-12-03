import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/product.dart';
import './pages/products.dart';
import './pages/products_admin.dart';
import './scoped-models/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    mainModel.autoAuthenticate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: mainModel,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
          buttonColor: Colors.red,
        ),
        // home: AuthenticatePage(),
        routes: {
          '/': (BuildContext context) =>
              mainModel.user == null ? AuthPage() : ProductsPage(),
          '/products': (BuildContext context) => ProductsPage(),
          '/admin': (BuildContext context) => ProductsAdminPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') return null;
          switch (pathElements[1]) {
            case 'product':
              final String productId = pathElements[2];
              return MaterialPageRoute<bool>(
                builder: (BuildContext context) => ProductPage(productId),
              );
            default:
              return null;
          }
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => ProductsPage());
        },
      ),
    );
  }
}
