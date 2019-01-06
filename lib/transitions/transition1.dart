import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart' show rootBundle;


void main() => runApp(new AnimationApp());

class AnimationApp extends StatefulWidget {
  _AnimationAppState createState() => _AnimationAppState();
}

class _AnimationAppState extends State<AnimationApp> with SingleTickerProviderStateMixin {
  ui.Image image1;
  ui.Image image2;

  AnimationController controller;
  Animation<double> animation;

  @override
  void initState(){
    controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    //call super before we 
    super.initState();
    //load dependencies
    _loadAssets();
  }

  void _loadAssets() async {
    image1 = await _loadAssetAsImage( "images/image1.png" );
    image2 = await _loadAssetAsImage( "images/image2.png" );

    setState((){});
  }

  Future<ui.Image> _loadAssetAsImage( String key ) async {
    var data = await rootBundle.load( key );
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      appBar: new AppBar(
        title: new Text("Demo"),
      ),
      body:Stack(
       children: [
         Positioned(
           top: 0,
           left: 0,
           right: 0,
           bottom: 0,
           child: image1 != null && image2 != null ? ImageEffectAnimation( animation:animation, image1:image1, image2:image2 ) : Container()
         )
       ]
      ),
      floatingActionButton: IconButton(icon:Icon(Icons.play_arrow), onPressed: (){
        controller.reset();
        controller.forward();
      },),
    ));
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

    print( size );

    Paint paintCircle = Paint()
    ..color = Color.fromARGB( (mix * 255.0).toInt(), 255, 0, 0);

    //canvas.drawCircle(Offset(200.0,200.0), 200.0, paintCircle );


    Paint paintImage = Paint()
    ..blendMode = BlendMode.srcATop
    ..color = Colors.red;

    int numStepsX = 10;
    int numStepsY = 10;
    
    double srcSizeX = 500.0 / numStepsX;
    double srcSizeY = 500.0 / numStepsY;
    double targetSizeX = size.width / numStepsX;
    double targetSizeY = size.width / numStepsY;

    canvas.drawImageRect(image1, Rect.fromLTRB(0.0,0.0,500.0,500.0), Rect.fromLTRB(0.0,0.0,size.width,size.width), paintImage);
    
    canvas.saveLayer(Rect.fromLTRB(0.0,0.0,size.width,size.width), Paint());
    for( int x = 0; x < numStepsX; x++ ){
      for( int y = 0; y < numStepsY; y++ ){
        canvas.drawCircle(
          Offset((x+0.5)*targetSizeX,(y+0.5)*targetSizeY),
          mix * targetSizeX,
          paintCircle
        );
      }
    }

    for( int x = 0; x < numStepsX; x++ ){
      for( int y = 0; y < numStepsY; y++ ){
        canvas.drawImageRect(image2, 
        Rect.fromLTWH(x*srcSizeX,y*srcSizeY,mix*srcSizeX,mix*srcSizeY), 
        Rect.fromLTWH(x*targetSizeX,y*targetSizeY,mix*targetSizeX,mix*targetSizeY), 
        paintImage);
        /*
        canvas.drawCircle(
          Offset((x+0.5)*targetSizeX,(y+0.5)*targetSizeY),
          mix * targetSizeX,
          paintCircle
        );*/
      }
    }
    
  }

  @override
  bool shouldRepaint(ImageEffectPainter oldDelegate) {
    return oldDelegate.image1 != this.image1 || oldDelegate.image2 != this.image2 || oldDelegate.mix != this.mix;
  }
}

