import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/locationCoordinates.dart';
import '../scoped-models/main.dart';
import '../widgets/form_inputs/location.dart';
import '../widgets/form_inputs/image.dart';
import '../widgets/platform/platform_progress_indicator.dart';
import '../widgets/platform/platform_elevation.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null,
    'location': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Widget _buildTitleTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Title'),
      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'Title field required and should be 5+ characters long.';
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Description'),
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      initialValue: product == null ? '' : product.description,
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return 'Description field required and should be 10+ characters long.';
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPriceTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Price'),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      initialValue: product == null ? '' : product.price.toString(),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number.';
        }
      },
      onSaved: (String value) {
        _formData['price'] =
            double.parse(value.replaceFirst(RegExp(r','), '.'));
      },
    );
  }

  Widget _buildSaveButton(product) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _isSaving
            ? Center(child: PlatformProgressIndicator())
            : RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () => _submitForm(model, product),
              );
      },
    );
  }

  void _setFormLocation(LocationCoordinates location) {
    _formData['location'] = location;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              SizedBox(height: 10.0),
              ImageInput(_setImage, product?.image),
              SizedBox(height: 10.0),
              LocationInput(_setFormLocation, product?.location),
              SizedBox(height: 10.0),
              _buildSaveButton(product),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(MainModel model, Product product) async {
    if (!_formKey.currentState.validate() ||
        (model.selectedProductId == null && _formData['image'] == null)) return;
    _formKey.currentState.save();
    setState(() {
      _isSaving = true;
    });
    try {
      if (model.selectedProductId == null) {
        await model.addProduct(
          title: _formData['title'],
          description: _formData['description'],
          image: _formData['image'],
          price: _formData['price'],
          location: _formData['location'],
        );
      } else {
        await model.updateProduct(
          title: _formData['title'],
          description: _formData['description'],
          image: _formData['image'],
          price: _formData['price'],
          location: _formData['location'],
        );
      }
      Navigator.pushReplacementNamed(context, '/products');
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Something went wrong!'),
            content: Text('Please try again!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductId == null
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  elevation: getPlatformThemeData(context),
                  title: Text('Edit product'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
