import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import '../elements/btn-round-icon.dart';
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
      RenderRepaintBoundary boundary =
          _renderKey.currentContext.findRenderObject();
      
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData.buffer.asUint8List();
      //write this
    } catch (e) {
      print(e);
    }

    return null;
  }

  void _onSubmitToModel( {AppModel model} ) async {
      Uint8List image = await _captureImage();
      JournalEntry entry = model.getEntryForToday();
      //create a new entry if required
      if( entry == null ){
        entry = await model.createEntryForToday();
      }

      await model.addEntryImage( entry, image );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, widget, model) {
        return Scaffold(
          /*appBar: new AppBar(title: new Text("Preview"), actions: [
            CancelButton(onPressed: () {
              Navigator.popUntil(context, (route) {
                if (route.isFirst) {
                  return true;
                } else {
                  return false;
                }
              });
            })
          ]),*/
          body: SafeArea(child: RepaintBoundary(
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
              }))),
          floatingActionButton: RoundIconButton(
              icon: Icons.check,
              onPressed: () async {
                //make the call to change the page first
                Navigator.popUntil(context, (route) {
                  return route.isFirst;
                });

                //now start on this task
                Uint8List image = await _captureImage();
                JournalEntry entry = model.getEntryForToday();
                //create a new entry if required
                if( entry == null ){
                  entry = await model.createEntryForToday();
                }

                await model.addEntryImage( entry, image );
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
                style: TextStyle(fontSize: 60.0, color: Colors.white))));
  }
}
