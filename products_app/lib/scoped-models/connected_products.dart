import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/user.dart';

mixin ConnectedProductsModel on Model {
  final String BASE_API_URL = 'https://flutter-products-552d4.firebaseio.com';
  List<Product> _products;
  int _selectedProductIndex;
  User _authenticatedUser;

  Future<void> fetchProducts() async {
    final http.Response response =
        await http.get('$BASE_API_URL/products.json');
    final Map<String, dynamic> responseData = json.decode(response.body);
    final List<Product> products = [];
    responseData.forEach((String name, dynamic productMap) {
      final Product product = Product(
        id: name,
        title: productMap['title'],
        description: productMap['description'],
        image: productMap['image'],
        price: productMap['price'],
        userEmail: productMap['userEmail'],
        userId: productMap['userId'],
      );
      products.add(product);
    });
    _products = products;
    notifyListeners();
  }

  Future<void> addProduct({
    @required String title,
    @required String description,
    @required String image,
    @required double price,
  }) async {
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://www.eatthis.com/wp-content/uploads/2017/10/dark-chocolate-bar-squares.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };
    final http.Response response = await http.post(
      '$BASE_API_URL/products.json',
      body: json.encode(productData),
    );
    final Map<String, dynamic> responseData = json.decode(response.body);
    final newProduct = Product(
      id: responseData['name'],
      title: title,
      description: description,
      image: image,
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id,
      price: price,
    );
    _products.add(newProduct);
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser = User(
      id: 'random',
      email: email,
      password: password,
    );
  }
}

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get products {
    if (_products == null) return null;
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_products == null) return [];
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selectedProductIndex;
  }

  Product get selectedProduct {
    if (_products == null) return null;
    return _selectedProductIndex == null
        ? null
        : _products[_selectedProductIndex];
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<void> updateProduct({
    @required String title,
    @required String description,
    @required String image,
    @required double price,
  }) async {
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image': selectedProduct.image,
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
    };
    final response = await http.put(
      '$BASE_API_URL/products/${selectedProduct.id}.json',
      body: json.encode(updateData),
    );
    final updatedProduct = Product(
      id: selectedProduct.id,
      title: title,
      description: description,
      image: image,
      price: price,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
    );
    _products[_selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  Future<void> deleteProduct() async {
    await http.delete('$BASE_API_URL/products/${selectedProduct.id}.json');
    _products.removeAt(_selectedProductIndex);
    notifyListeners();
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: newFavoriteStatus);
    _products[_selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
