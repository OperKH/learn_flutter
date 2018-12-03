import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextFieldController =
      TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  bool isAuthorizing = false;

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      image: AssetImage('assets/background.jpg'),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'E-Mail',
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          filled: true,
          fillColor: Colors.white,
        ),
        obscureText: true,
        controller: _passwordTextFieldController,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return 'Password invalid';
          }
        },
        onSaved: (String value) {
          _formData['password'] = value;
        },
      ),
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return _authMode == AuthMode.Login
        ? Container()
        : Container(
            margin: EdgeInsets.only(top: 10.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
              validator: (String value) {
                if (value != _passwordTextFieldController.text) {
                  return 'Passwords don\'t match';
                }
              },
            ),
          );
  }

  Widget _buildAcceptSwitch() {
    return _authMode == AuthMode.Login
        ? Container()
        : SwitchListTile(
            value: _formData['acceptTerms'],
            onChanged: (bool value) {
              setState(() {
                _formData['acceptTerms'] = value;
              });
            },
            title: Text('Accept Terms'),
          );
  }

  Widget _buildSwitchModeBtn() {
    return FlatButton(
      onPressed: () {
        setState(() {
          _authMode =
              _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
        });
      },
      child:
          Text('Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
    );
  }

  Widget _buildSubmitBtn() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return isAuthorizing
            ? CircularProgressIndicator()
            : RaisedButton(
                textColor: Colors.white,
                child:
                    Text('${_authMode == AuthMode.Login ? 'LOGIN' : 'SIGNUP'}'),
                onPressed: () => _submitForm(model),
              );
      },
    );
  }

  void _submitForm(MainModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    try {
      setState(() {
        isAuthorizing = true;
      });
      final Map<String, dynamic> status = await model.authenticate(
          _formData['email'], _formData['password'], _authMode);
      setState(() {
        isAuthorizing = false;
      });
      if (status['success'] == true) {
        Navigator.pushReplacementNamed(context, '/products');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Something went wrong!'),
              content: Text(status['message']),
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
    } catch (e) {
      setState(() {
        isAuthorizing = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation deviceOrientation = MediaQuery.of(context).orientation;
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double width = deviceOrientation == Orientation.landscape
        ? deviceWidth * 0.6
        : deviceWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildEmailTextField(),
                    _buildPasswordTextField(),
                    _buildPasswordConfirmTextField(),
                    _buildAcceptSwitch(),
                    SizedBox(height: 10.0),
                    _buildSwitchModeBtn(),
                    SizedBox(height: 10.0),
                    _buildSubmitBtn(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
