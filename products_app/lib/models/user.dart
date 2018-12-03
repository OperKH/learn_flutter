import 'package:flutter/material.dart';

class User {
  final String id;
  final String token;
  final String email;
  final String password;

  User({
    @required this.id,
    @required this.token,
    @required this.email,
    @required this.password,
  });
}
