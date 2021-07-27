import 'dart:async';
import 'package:flutter/material.dart';
import 'main_page.dart';

StreamController<List> streamController = new StreamController<List>();

void main() {
  runApp(PageOne());
}

class PageOne extends StatelessWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "SolatApp",
        home: HomePage(streamController.stream),
        debugShowCheckedModeBanner: false);
  }
}
