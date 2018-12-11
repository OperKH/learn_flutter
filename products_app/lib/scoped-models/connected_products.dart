import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dio/dio.dart' show Response;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/subjects.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/locationCoordinates.dart';

import '../api/auth.dart' as auth;
import '../api/productsApi.dart' as productsApi;
import '../api/storeImage.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products;
  String _selectedProductId;
  User _authenticatedUser;
  FlutterSecureStorage _secureStorage = FlutterSecureStorage();
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

      await Future.wait([
        _secureStorage.write(key: 'userId', value: responseData['localId']),
        _secureStorage.write(key: 'userToken', value: responseData['idToken']),
        _secureStorage.write(key: 'userEmail', value: email),
        _secureStorage.write(key: 'userPassword', value: password),
        _secureStorage.write(
            key: 'expiryTime', value: expiryTime.toIso8601String()),
      ]);

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
    await Future.wait([
      _secureStorage.delete(key: 'userToken'),
      _secureStorage.delete(key: 'userId'),
      _secureStorage.delete(key: 'userEmail'),
      _secureStorage.delete(key: 'userPassword'),
      _secureStorage.delete(key: 'expiryTime'),
    ]);
    _userSubject.add(false);
    notifyListeners();
  }

  Future<void> autoAuthenticate() async {
    final String token = await _secureStorage.read(key: 'userToken');
    if (token == null) return null;
    final String expiryTimeString =
        await _secureStorage.read(key: 'expiryTime');
    final DateTime expiryTime = DateTime.parse(expiryTimeString);
    final DateTime now = DateTime.now();
    if (expiryTime.isBefore(now)) {
      await logout();
      return null;
    }
    final String id = await _secureStorage.read(key: 'userId');
    final String email = await _secureStorage.read(key: 'userEmail');
    final String password = await _secureStorage.read(key: 'userPassword');

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
    try {
      final Response response = await productsApi.getProducts();
      final Map<String, dynamic> responseData = response.data;
      final List<Product> products = [];
      responseData.forEach((String name, dynamic productMap) {
        if (isOnlyForUser && productMap['userId'] != _authenticatedUser.id)
          return;
        final Map<String, dynamic> wishlistUsers = productMap['wishlistUsers'];
        final bool isFavorite = wishlistUsers == null
            ? false
            : wishlistUsers.containsKey(_authenticatedUser.id);
        final latitude = productMap['locationLatitude'];
        final longitude = productMap['locationLongitude'];
        final LocationCoordinates location =
            LocationCoordinates(latitude: latitude, longitude: longitude);
        final Product product = Product(
          id: name,
          title: productMap['title'],
          description: productMap['description'],
          image: productMap['image'],
          imagePath: productMap['imagePath'],
          price: productMap['price'],
          userEmail: productMap['userEmail'],
          userId: productMap['userId'],
          isFavorite: isFavorite,
          location: location,
        );
        products.add(product);
      });
      _products = products;
      notifyListeners();
    } catch (e) {}
  }

  Future<Map<String, dynamic>> _uploadImage(File image,
      {String imagePath}) async {
    final response = await storeImage(image, imagePath);
    return response.data;
  }

  Future<void> addProduct({
    @required String title,
    @required String description,
    @required File image,
    @required double price,
    @required LocationCoordinates location,
  }) async {
    try {
      final Map<String, dynamic> uploadedData = await _uploadImage(image);
      final Map<String, dynamic> productData = {
        'title': title,
        'description': description,
        'image': uploadedData['imageUrl'],
        'imagePath': uploadedData['imagePath'],
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
        image: uploadedData['imageUrl'],
        imagePath: uploadedData['imagePath'],
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        price: price,
        location: location,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {}
  }

  Future<void> updateProduct({
    @required String title,
    @required String description,
    @required File image,
    @required double price,
    @required LocationCoordinates location,
  }) async {
    try {
      String imageUrl = selectedProduct.image;
      String imagePath = selectedProduct.imagePath;
      if (image != null) {
        final Map<String, dynamic> uploadedData =
            await _uploadImage(image, imagePath: imagePath);
        imageUrl = uploadedData['imageUrl'];
        imagePath = uploadedData['imagePath'];
      }
      final Map<String, dynamic> updateData = {
        'title': title,
        'description': description,
        'image': imageUrl,
        'imagePath': imagePath,
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
        image: imageUrl,
        imagePath: imagePath,
        price: price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        location: location,
      );
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> deleteProduct() async {
    try {
      await productsApi.deleteProduct(selectedProduct.id);
      _products.removeAt(selectedProductIndex);
      notifyListeners();
    } catch (e) {}
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
      imagePath: product.imagePath,
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
        imagePath: product.imagePath,
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
        imagePath: product.imagePath,
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
