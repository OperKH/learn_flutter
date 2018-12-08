import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dio/dio.dart' show Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/locationCoordinates.dart';

import '../api/auth.dart' as auth;
import '../api/productsApi.dart' as productsApi;

mixin ConnectedProductsModel on Model {
  List<Product> _products;
  String _selectedProductId;
  User _authenticatedUser;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
}

mixin UserModel on ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  String get token {
    if (_authenticatedUser == null) return null;
    return _authenticatedUser.token;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    final Response response = mode == AuthMode.Login
        ? await auth.loginUser(data)
        : await auth.signupNewUser(data);
    final Map<String, dynamic> responseData = response.data;

    if (responseData.containsKey('idToken')) {
      final int expiresIn = int.parse(responseData['expiresIn']);
      setAuthTimoute(expiresIn);

      final DateTime expiryTime =
          DateTime.now().add(Duration(seconds: expiresIn));
      final SharedPreferences prefs = await _prefs;
      prefs.setString('userId', responseData['localId']);
      prefs.setString('userToken', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userPassword', password);
      prefs.setString('expiryTime', expiryTime.toIso8601String());

      _authenticatedUser = User(
        id: responseData['localId'],
        token: responseData['idToken'],
        email: email,
        password: password,
      );
      _userSubject.add(true);
    }
    return response.data;
  }

  Future<void> logout() async {
    print('Logout');
    _authenticatedUser = null;
    _authTimer?.cancel();
    final SharedPreferences prefs = await _prefs;
    await Future.wait([
      prefs.remove('userToken'),
      prefs.remove('userId'),
      prefs.remove('userEmail'),
      prefs.remove('userPassword'),
      prefs.remove('expiryTime'),
    ]);
    _userSubject.add(false);
    notifyListeners();
  }

  Future<void> autoAuthenticate() async {
    final SharedPreferences prefs = await _prefs;
    final String token = prefs.getString('userToken');
    if (token == null) return null;
    final String expiryTimeString = prefs.getString('expiryTime');
    final DateTime expiryTime = DateTime.parse(expiryTimeString);
    final DateTime now = DateTime.now();
    if (expiryTime.isBefore(now)) {
      await logout();
      return null;
    }
    final String id = prefs.getString('userId');
    final String email = prefs.getString('userEmail');
    final String password = prefs.getString('userPassword');

    _authenticatedUser = User(
      id: id,
      token: token,
      email: email,
      password: password,
    );

    _userSubject.add(true);

    final int expireIn = expiryTime.difference(now).inSeconds;
    setAuthTimoute(expireIn);

    notifyListeners();
  }

  void setAuthTimoute(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
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

  Future<void> fetchProducts({bool isOnlyForUser = false}) async {
    _products = null;
    notifyListeners();
    final Response response = await productsApi.getProducts();
    final Map<String, dynamic> responseData = response.data;
    final List<Product> products = [];
    responseData.forEach((String name, dynamic productMap) {
      final Map<String, dynamic> wishlistUsers = productMap['wishlistUsers'];
      final bool isFavorite = wishlistUsers == null
          ? false
          : wishlistUsers.containsKey(_authenticatedUser.id);
      final latitude = productMap['locationLatitude'];
      final longitude = productMap['locationLongitude'];
      final LocationCoordinates location =
          (latitude == null || longitude == null)
              ? null
              : LocationCoordinates(latitude: latitude, longitude: longitude);
      final Product product = Product(
        id: name,
        title: productMap['title'],
        description: productMap['description'],
        image: productMap['image'],
        price: productMap['price'],
        userEmail: productMap['userEmail'],
        userId: productMap['userId'],
        isFavorite: isFavorite,
        location: location,
      );
      products.add(product);
    });
    _products = isOnlyForUser
        ? products.where((Product product) {
            return product.userId == _authenticatedUser.id;
          }).toList()
        : products;
    notifyListeners();
  }

  Future<void> addProduct({
    @required String title,
    @required String description,
    @required String image,
    @required double price,
    @required LocationCoordinates location,
  }) async {
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://www.eatthis.com/wp-content/uploads/2017/10/dark-chocolate-bar-squares.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'locationLatitude': location.latitude,
      'locationLongitude': location.longitude,
    };
    final Response response = await productsApi.createProduct(productData);
    final Map<String, dynamic> responseData = response.data;
    final newProduct = Product(
      id: responseData['name'],
      title: title,
      description: description,
      image: image,
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id,
      price: price,
      location: location,
    );
    _products.add(newProduct);
    notifyListeners();
  }

  Future<void> updateProduct({
    @required String title,
    @required String description,
    @required String image,
    @required double price,
    @required LocationCoordinates location,
  }) async {
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image': selectedProduct.image,
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
      'locationLatitude': location.latitude,
      'locationLongitude': location.longitude,
    };
    await productsApi.updateProduct(updateData, selectedProduct.id);
    final updatedProduct = Product(
      id: selectedProduct.id,
      title: title,
      description: description,
      image: image,
      price: price,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
      location: location,
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

  Future<void> toggleProductFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final int index = selectedProductIndex;
    final Product product = _products[index];

    final Product updatedProduct = Product(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      image: product.image,
      userEmail: product.userEmail,
      userId: product.userId,
      isFavorite: newFavoriteStatus,
      location: product.location,
    );
    _products[index] = updatedProduct;
    notifyListeners();

    try {
      if (newFavoriteStatus) {
        await productsApi.likeProduct(
            selectedProduct.id, _authenticatedUser.id);
      } else {
        await productsApi.unlikeProduct(
            selectedProduct.id, _authenticatedUser.id);
      }
      final Product updatedProduct = Product(
        id: product.id,
        title: product.title,
        description: product.description,
        price: product.price,
        image: product.image,
        userEmail: product.userEmail,
        userId: product.userId,
        isFavorite: newFavoriteStatus,
        location: product.location,
      );
      _products[index] = updatedProduct;
      notifyListeners();
    } catch (e) {
      final Product updatedProduct = Product(
        id: product.id,
        title: product.title,
        description: product.description,
        price: product.price,
        image: product.image,
        userEmail: product.userEmail,
        userId: product.userId,
        isFavorite: !newFavoriteStatus,
        location: product.location,
      );
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
