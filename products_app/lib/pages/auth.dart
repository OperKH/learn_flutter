import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dio/dio.dart' show DioError;
import 'package:local_auth/local_auth.dart';

import '../scoped-models/main.dart';
import '../models/auth.dart';
import '../widgets/platform/platform_progress_indicator.dart';
import '../widgets/platform/platform_elevation.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextFieldController =
      TextEditingController();
  final LocalAuthentication localAuth = LocalAuthentication();
  AuthMode _authMode = AuthMode.Login;
  bool isAuthorizing = false;
  AnimationController _animationController;
  Animation<Offset> _slideAnimation;
  bool _canAuthenticateByCredentials = false;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _initBiometricLogin();
    super.initState();
  }

  Future<void> _initBiometricLogin() async {
    bool canCheckBiometrics = false;
    bool canAuthenticateByCredentials = false;
    try {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
      canAuthenticateByCredentials =
          await mainModel.canAuthenticateByCredentials;
    } catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _canAuthenticateByCredentials = canAuthenticateByCredentials;
      _canCheckBiometrics = canCheckBiometrics;
    });
    if (canAuthenticateByCredentials && canCheckBiometrics) {
      await _loginByBiometric();
    }
  }

  Future<void> _loginByBiometric() async {
    try {
      final authenticated = await localAuth.authenticateWithBiometrics(
        localizedReason: 'Login',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      if (authenticated) {
        setState(() {
          isAuthorizing = true;
        });
        await mainModel.autoAuthenticateFromSecureStorage();
        setState(() {
          isAuthorizing = false;
        });
      }
    } catch (e) {}
  }

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
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          TextFormField(
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
          Positioned(
            right: 0.0,
            child: (_canAuthenticateByCredentials && _canCheckBiometrics)
                ? GestureDetector(
                    onTap: _loginByBiometric,
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.fingerprint,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              filled: true,
              fillColor: Colors.white,
            ),
            obscureText: true,
            validator: (String value) {
              if (_authMode == AuthMode.Signup &&
                  value != _passwordTextFieldController.text) {
                return 'Passwords don\'t match';
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptSwitch() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: SwitchListTile(
          value: _formData['acceptTerms'],
          onChanged: (bool value) {
            setState(() {
              _formData['acceptTerms'] = value;
            });
          },
          title: Text('Accept Terms'),
        ),
      ),
    );
  }

  Widget _buildSwitchModeBtn() {
    return FlatButton(
      onPressed: () {
        if (_authMode == AuthMode.Login) {
          setState(() {
            _authMode = AuthMode.Signup;
          });
          _animationController.forward();
        } else {
          setState(() {
            _authMode = AuthMode.Login;
          });
          _animationController.reverse();
        }
      },
      child:
          Text('Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
    );
  }

  Widget _buildSubmitBtn() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return isAuthorizing
            ? PlatformProgressIndicator()
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
    setState(() {
      isAuthorizing = true;
    });
    try {
      await model.authenticate(
          _formData['email'], _formData['password'], _authMode);
      Navigator.pushReplacementNamed(context, '/products');
    } on DioError catch (e) {
      String msg = _getAuthErrorMsg(e.response.data);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Auth Error!'),
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e);
    }
    setState(() {
      isAuthorizing = false;
    });
  }

  String _getAuthErrorMsg(dynamic responseData) {
    String message = 'Something went wrong!';
    switch (responseData['error']['message']) {
      case 'EMAIL_EXISTS':
        message = 'This email alredy exists!';
        break;
      case 'EMAIL_NOT_FOUND':
        message = 'This user not registered!';
        break;
      case 'INVALID_PASSWORD':
        message = 'The password is invalid!';
        break;
      case 'EMAIL_NOT_FOUND':
        message = 'This user has been disabled!';
        break;
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        message = 'Too many attempts please try later!';
        break;
    }
    return message;
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
        elevation: getPlatformThemeData(context),
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
