import 'package:flutter/material.dart';

final ThemeData _iOS = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.grey,
  accentColor: Colors.blue,
  buttonColor: Colors.blue,
);
final ThemeData _android = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepOrange,
  accentColor: Colors.deepPurple,
  buttonColor: Colors.deepPurple,
);

ThemeData getPlatformThemeData(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS ? _iOS : _android;
}
