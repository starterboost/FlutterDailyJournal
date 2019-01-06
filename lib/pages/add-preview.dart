import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import '../elements/btn-round-icon.dart';
import '../elements/btn-cancel.dart';
import '../model/app-model.dart';

class AddPreviewPage extends StatefulWidget {
  @override
  AddPreviewPageState createState() {
    return new AddPreviewPageState();
  }
}

class AddPreviewPageState extends State<AddPreviewPage> {
  GlobalKey _renderKey = GlobalKey();

  Future<Uint8List> _captureImage() async {
    try {
      print("Step1");
      RenderRepaintBoundary boundary =
          _renderKey.currentContext.findRenderObject();
      print("Step2");

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      print("Step3");

      print("Image ${image.width} x ${image.height}");
      
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      print("Step4");
      
      return byteData.buffer.asUint8List();
    } catch (e) {
      print(e);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, widget, model) {
        return Scaffold(
          appBar: new AppBar(title: new Text("Preview"), actions: [
            CancelButton(onPressed: () {
              Navigator.popUntil(context, (route) {
                if (route.isFirst) {
                  return true;
                } else {
                  return false;
                }
              });
            })
          ]),
          body: RepaintBoundary(
              key: _renderKey,
              child: ScopedModelDescendant<AppModel>(
                  builder: (context, widget, model) {
                if (model.preview is ImageSlide) {
                  return _ImageSlidePreview(model: model.preview as ImageSlide);
                } else if (model.preview is AssetEntitySlide) {
                  return _AssetEntitySlidePreview(
                      model: model.preview as AssetEntitySlide);
                } else if (model.preview is TextSlide) {
                  return _TextSlidePreview(model: model.preview as TextSlide);
                }

                return Container();
              })),
          floatingActionButton: RoundIconButton(
              icon: Icons.check,
              onPressed: () async {
                print("onPressedA");
                Uint8List image = await _captureImage();
                print("onPressedB ${image.length}");
                model.images.add(image);
                print("onPressedC");
                //model.preview = null;

                Navigator.popUntil(context, (route) {
                  return route.isFirst;
                });
                print("onPressedD");
              }),
        );
      },
    );
  }
}

class _AssetEntitySlidePreview extends StatefulWidget {
  _AssetEntitySlidePreview({Key key, @required this.model}) : super(key: key);
  final AssetEntitySlide model;

  @override
  _AssetEntitySlidePreviewState createState() {
    return new _AssetEntitySlidePreviewState();
  }
}

class _AssetEntitySlidePreviewState extends State<_AssetEntitySlidePreview> {
  Uint8List _imageData;
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    //load the basic image
    _loadImage();
  }

  void _loadImage() async {
    //load the basic
    _imageData = await widget.model.asset.thumbDataWithSize(50, 50);
    if (mounted) {
      setState(() {});
      //load the detailed
      _imageData = await widget.model.asset.thumbDataWithSize(500, 500);
      if (mounted) {
        setState(() {
          //hide the progress
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: _imageData != null
              ? Image.memory(_imageData, fit: BoxFit.cover)
              : Container()),
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container())
    ]);
  }
}

class _ImageSlidePreview extends StatefulWidget {
  _ImageSlidePreview({Key key, this.model}) : super(key: key);
  final ImageSlide model;

  _ImageSlidePreviewState createState() => _ImageSlidePreviewState();
}

class _ImageSlidePreviewState extends State<_ImageSlidePreview> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Image.file(widget.model.file, fit: BoxFit.cover))
    ]);
  }
}

class _TextSlidePreview extends StatefulWidget {
  _TextSlidePreview({Key key, this.model}) : super(key: key);
  final TextSlide model;

  _TextSlidePreviewState createState() => _TextSlidePreviewState();
}

class _TextSlidePreviewState extends State<_TextSlidePreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: widget.model.color),
        child: Center(
            child: Text(widget.model.text,
                style: TextStyle(fontSize: 30.0, color: Colors.white))));
  }
}
