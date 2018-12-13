import 'package:flutter/material.dart';

const double _iOS = 0.0;
const double _android = 4.0;

double getPlatformThemeData(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS ? _iOS : _android;
}
