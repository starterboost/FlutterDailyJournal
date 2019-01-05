import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './pages/home.dart';
import './pages/add-slide.dart';
import './pages/add-text-slide.dart';
import './pages/add-image-slide.dart';
import './pages/add-photo-slide.dart';
import './pages/add-preview.dart';


void main() => runApp(new JournageApp());

class JournageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        // When we navigate to the "/" route, build the FirstScreen Widget
        '/': (context) => HomePage(),
        '/add-slide': (context) => AddSlidePage(),
        '/add-text-slide': (context) => AddTextSlidePage(),
        '/add-text-color-slide': (context) => AddTextColorSlidePage(),
        '/add-image-slide': (context) => AddImageSlidePage(),
        '/add-photo': (context) => AddPhotoSlidePage(),
        '/add-preview': (context) => AddPreviewPage(),
      }
    );
  }
}
