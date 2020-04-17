import 'package:flutter/material.dart';
import 'package:sqlite_demo/pages/home.dart';
import 'package:sqlite_demo/pages/create.dart';
import 'package:sqlite_demo/pages/delete.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => Home(),
      '/create': (context) => Create(() {}, () {}),
      '/delete': (context) => Delete(() {}, () {}),
    },
  ));
}
