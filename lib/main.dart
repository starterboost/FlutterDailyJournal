import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './pages/home.dart';
import './pages/add-slide.dart';
import './pages/add-text-slide.dart';
import './pages/add-image-slide.dart';
import './pages/add-photo-slide.dart';
import './pages/add-preview.dart';

import 'package:scoped_model/scoped_model.dart';
import './model/app-model.dart';

import 'package:flutter/services.dart';

void main(){
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(new JournageApp());
  });
}

class JournageApp extends StatefulWidget {
  @override
  JournageAppState createState() {
    return new JournageAppState();
  }
}

class JournageAppState extends State<JournageApp> {
  AppModel _model;

  @override
    void initState() {
      _model = new AppModel();
      super.initState();
    }

  @override
  Widget build(BuildContext context) {
    return new ScopedModel<AppModel>(
        model: _model,
        child: MaterialApp(debugShowCheckedModeBanner: false,initialRoute: '/', routes: {
          // When we navigate to the "/" route, build the FirstScreen Widget
          '/': (context) => HomePage(),
          '/add-slide': (context) => AddSlidePage(),
          '/add-text-slide': (context) => AddTextSlidePage(),
          '/add-text-color-slide': (context) => AddTextColorSlidePage(),
          '/add-image-slide': (context) => AddImageSlidePage(),
          '/add-photo': (context) => AddPhotoSlidePage(),
          '/add-preview': (context) => AddPreviewPage(),
        }));
  }
}
