import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' show Response;

import '../models/product.dart';
import '../models/user.dart';

import '../api/auth.dart' as auth;
import '../api/productsApi.dart' as productsApi;

mixin ConnectedProductsModel on Model {
  List<Product> _products;
  String _selectedProductId;
  User _authenticatedUser;
}

mixin UserModel on ConnectedProductsModel {
  Future<Map<String, dynamic>> signup(String email, String password) async {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    final response = await auth.signupNewUser(data);
    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);
    bool hasError = true;
    String message = 'Something went wrong!';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeded!';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email alredy exists!';
    }
    return {'success': !hasError, 'message': message};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
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

  String get selectedProductId {
    return _selectedProductId;
  }

  int get selectedProductIndex {
    if (_products == null || _selectedProductId == null) return -1;
    return _products
        .indexWhere((Product product) => product.id == _selectedProductId);
  }

  Product get selectedProduct {
    if (_products == null) return null;
    return selectedProductId == null
        ? null
        : _products
            .firstWhere((Product product) => product.id == selectedProductId);
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<void> fetchProducts() async {
    final response = await productsApi.getProducts();
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
    final response = await productsApi.createProduct(productData);
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
    final response =
        await productsApi.updateProduct(updateData, selectedProduct.id);
    final updatedProduct = Product(
      id: selectedProduct.id,
      title: title,
      description: description,
      image: image,
      price: price,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
    );
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  Future<void> deleteProduct() async {
    await productsApi.deleteProduct(selectedProduct.id);
    _products.removeAt(selectedProductIndex);
    notifyListeners();
  }

  void selectProduct(String productId) {
    _selectedProductId = productId;
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
      isFavorite: newFavoriteStatus,
    );
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
