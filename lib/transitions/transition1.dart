import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';

import 'dart:typed_data';
import 'package:scoped_model/scoped_model.dart';
import '../model/app-model.dart';

class Transition1 extends StatefulWidget {
  Transition1({Key key, @required this.image1, @required this.image2}):super(key:key);
  final int image1;
  final int image2;

  _Transition1State createState() => _Transition1State();
}

class _Transition1State extends State<Transition1> with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation<double> animation;

  ui.Image _image1;
  ui.Image _image2;
  int image1;
  int image2;

  @override
  void initState(){
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    controller.forward();
    controller.addStatusListener(( AnimationStatus status ){
      if( controller.value == 1.0 ){
        controller.reverse();
      }else if( controller.value == 0.0 ){
        controller.forward();
      }
    });

    //call super before we 
    super.initState();
    //load dependencies
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    if( image1 != widget.image1 ){
      image1 = widget.image1;
      _image1 = await _imageFromDb( widget.image1 );
    }

    if( image2 != widget.image2 ){
      image2 = widget.image2;
      _image2 = await _imageFromDb( widget.image2 );
    }

    setState((){});
  }

  @override void didUpdateWidget( Transition1 oldWidget) {
      //detect change of the enableFullAsset
      _loadAssets();
      //did update widget
      super.didUpdateWidget(oldWidget);
  }

  Future<ui.Image> _imageFromFilePath( String path ) async {
    File file = File( path );
    List<dynamic> data = await file.readAsBytes();
    return _imageFromMemory( data );
  }
  
  Future<ui.Image> _imageFromDb( int id ) async {
    AppModel model = ScopedModel.of<AppModel>(context);
    Uint8List data = await model.loadImage( id );
    return _imageFromMemory( data );
  }
  
  Future<ui.Image> _imageFromMemory( Uint8List data ) async {
    var codec = await ui.instantiateImageCodec(data);
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  @override dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _image1 != null && _image2 != null ? ImageEffectAnimation( animation:animation, image1:_image1, image2:_image2 ) : Container();
  }
}

class ImageEffectAnimation extends AnimatedWidget{
  
  ImageEffectAnimation({Key key, Animation<double> animation, this.image1, this.image2})
      : super(key: key, listenable: animation);

  final ui.Image image1;
  final ui.Image image2;

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return CustomPaint(painter: ImageEffectPainter( image1:image1, image2:image2, mix:animation.value ));
  }

}

class ImageEffectPainter extends CustomPainter{
  ImageEffectPainter({@required this.image1, @required this.image2, this.mix});
  final ui.Image image1;
  final ui.Image image2;
  final double mix;

  @override
  void paint(Canvas canvas, Size size) {

    Paint paintCircle = Paint()
    ..color = Color.fromARGB( (mix * 255.0).toInt(), 255, 0, 0);

    //canvas.drawCircle(Offset(200.0,200.0), 200.0, paintCircle );


    Paint paintImage = Paint()
    ..blendMode = BlendMode.srcATop
    ..color = Colors.red;

    int numStepsX = 10;
    int numStepsY = 15;
    
    double width = image1.width.toDouble();
    double height = image1.height.toDouble();

    double srcSizeX = width / numStepsX;
    double srcSizeY = height / numStepsY;
    double targetSizeX = size.width / numStepsX;
    double targetSizeY = size.height / numStepsY;

    canvas.drawImageRect(image1, Rect.fromLTRB(0.0,0.0,width,height), Rect.fromLTRB(0.0,0.0,size.width,size.height), paintImage);
    
    canvas.saveLayer(Rect.fromLTRB(0.0,0.0,size.width,size.height), Paint());
    for( int x = 0; x < numStepsX; x++ ){
      for( int y = 0; y < numStepsY; y++ ){
        /*canvas.drawCircle(
          Offset((x+0.5)*targetSizeX,(y+0.5)*targetSizeY),
          mix * targetSizeX,
          paintCircle
        );*/
        canvas.drawRect(
          Rect.fromLTWH(
            (x+0.5-mix*0.5)*targetSizeX,
            (y+0.5-mix*0.5)*targetSizeY,
            mix*targetSizeX,
            mix*targetSizeY,
          ),
          paintCircle
        );
      }
    }

    canvas.drawImageRect(image2, Rect.fromLTRB(0.0,0.0,width,height), Rect.fromLTRB(0.0,0.0,size.width,size.height), paintImage);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ImageEffectPainter oldDelegate) {
    return oldDelegate.image1 != this.image1 || oldDelegate.image2 != this.image2 || oldDelegate.mix != this.mix;
  }
}

