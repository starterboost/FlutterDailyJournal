import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:scoped_model/scoped_model.dart';

import '../elements/camera.dart';
import '../elements/btn-round-icon.dart';
import '../model/app-model.dart';

class AddPhotoSlidePage extends StatefulWidget {
  @override
  AddPhotoSlidePageState createState() {
    return new AddPhotoSlidePageState();
  }
}

class AddPhotoSlidePageState extends State<AddPhotoSlidePage> {
  File capture;

  /*
   * VARIOUS BUGS WITH THE CAMERA - WAITING FOR BUG WITH THE ROTATION TO BE FIXED SO THAT WE CAN UPGRADE
   */

  @override
  Widget build(BuildContext context) {
    bool hasCapture = capture == null ? false : true;

    return ScopedModelDescendant<AppModel>(builder: (context, child, model) {
      return Scaffold(
          appBar: new AppBar(
            title: new Text("Take Photo"),
          ),
          body: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: hasCapture
                  ? Container(decoration:BoxDecoration(color:Colors.red), child:Image.file(capture,fit:BoxFit.cover))
                  : CameraWidget(onCapture: (File file) {
                      //load this
                      setState(() {
                        capture = file;
                      });
                    })),
          floatingActionButton: hasCapture
              ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RoundIconButton(
                      icon: Icons.refresh,
                      onPressed: () {
                        setState(() {
                          capture = null;
                        });
                      }),
                  Container(width: 10.0, height: 0.0),
                  RoundIconButton(
                      icon: Icons.check,
                      onPressed: () {
                        //go to preview
                        model.preview = ImageSlide(file: capture);
                        Navigator.pushNamed(context, "/add-preview");
                      })
                ])
              : null);
    });
  }
}
