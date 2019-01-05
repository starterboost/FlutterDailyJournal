import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../elements/camera.dart';
import '../elements/btn-round-icon.dart';

class AddPhotoSlidePage extends StatefulWidget {
  @override
  AddPhotoSlidePageState createState() {
    return new AddPhotoSlidePageState();
  }
}

class AddPhotoSlidePageState extends State<AddPhotoSlidePage> {
  File capture;

  @override
  Widget build(BuildContext context) {
    bool hasCapture = capture == null ? false : true;

    return Scaffold(
        appBar: new AppBar(
          title: new Text("Take Photo"),
        ),
        body: hasCapture
            ? Image.file(capture)
            : CameraWidget(onCapture: (File file) {
                setState(() {
                  capture = file;
                });
              }),
        floatingActionButton: hasCapture
            ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RoundIconButton(icon: Icons.refresh, onPressed: () {
                  setState((){
                    capture = null;
                  });
                }),
                Container(width:10.0,height:0.0),
                RoundIconButton(icon: Icons.check, onPressed: () {
                  //go to preview
                  Navigator.pushNamed(context, "/add-preview");
                })
              ])
            : null);
  }
}
