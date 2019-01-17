import 'package:flutter/material.dart';
import '../../model/app-model.dart';
import '../home.dart';

void main() {
  runApp(
    AppModelContainer(
      child: MaterialApp(debugShowCheckedModeBanner: false,initialRoute: '/', routes: {
            '/': (context) => HomePage()
      })
    )
  );
}