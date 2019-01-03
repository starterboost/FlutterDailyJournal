import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart' show rootBundle;

List<CameraDescription> cameras;


int _getAlphaFromOpacity(double opacity) => (opacity * 255).round();

Future<void> main() async {
  cameras = await availableCameras();
  runApp(RenderApp());
}


class RenderApp extends StatefulWidget {
  _RenderAppState createState() => _RenderAppState();
}

class _RenderAppState extends State<RenderApp> with SingleTickerProviderStateMixin {
  ui.Image image1;
  ui.Image image2;

  AnimationController controller;
  Animation<double> animation;

  @override
  void initState(){
    controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);

    // TODO: implement initState
    super.initState();
    //load dependencies
    _loadAssets();

    controller.forward();
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
    ..color = Color.fromARGB( (255.0).toInt(), 255, 0, 0);

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

    //canvas.drawImageRect(image1, Rect.fromLTRB(0.0,0.0,500.0,500.0), Rect.fromLTRB(0.0,0.0,400.0,400.0), paintImage);
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
    
    canvas.drawImageRect(image2, Rect.fromLTRB(0.0,0.0,500.0,500.0), Rect.fromLTRB(0.0,0.0,size.width,size.width), paintImage);
    /*
    for( int x = 0; x < numStepsX; x++ ){
      for( int y = 0; y < numStepsY; y++ ){
        canvas.drawImageRect(
          image2, 
          Rect.fromLTWH((x+0.5*(1-mix))*srcSizeX,(y+0.5*(1-mix))*srcSizeY,mix*srcSizeX,mix*srcSizeY), 
          Rect.fromLTWH((x+0.5*(1-mix))*targetSizeX,(y+0.5*(1-mix))*targetSizeX,mix * targetSizeX,mix * targetSizeY),
          paintImage
        );
      }
    }*/

    /*
    //try creating a new layer

    //canvas.save();
    canvas.saveLayer(Rect.fromLTRB(100.0,100.0,200.0,200.0), Paint());

    paintCircle.color = Color.fromARGB( (mix * 255.0).toInt(), 255, 255, 255);
    canvas.drawCircle(Offset(100.0,100.0), 100.0, paintCircle );
    canvas.drawImageRect(image1, Rect.fromLTRB(0.0,0.0,500.0,500.0), Rect.fromLTRB(0.0,0.0,200.0,200.0), paintImage);
    */
    

  }

  @override
  bool shouldRepaint(ImageEffectPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;//oldDelegate.image1 != this.image1 && oldDelegate.image2 != this.image2 && oldDelegate.mix != this.mix;
  }}

class SlideShow extends StatefulWidget {
  SlideShow({Key key, this.children}): super(key:key);
  final List<Widget> children;
  
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends State<SlideShow> {

  ui.Image image = null;

  Widget _getChildAt( int index ){
    int numChildren = widget.children.length;
    return numChildren > 0 ? widget.children.elementAt(index % numChildren ) : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ChildSnapshot( child: _getChildAt( 1 ), onComplete:( image ){
          this.image = image;
          setState((){});
        }),
        _getChildAt( 0 ),
        //image != null ? CustomPaint( painter: ImagePainter( image ) )  : Container()
      ]
    );
  }
}


class ImagePainter extends CustomPainter{
  ui.Image image;
  ImagePainter( this.image ): super();

  @override
  void paint(ui.Canvas canvas, ui.Size size) {

    if( image != null ){
      Paint paint = new Paint()
      ..colorFilter = ColorFilter.mode(Colors.orange, BlendMode.multiply);
      // TODO: implement paint

      // Path path = Path()
      // ..addRect(Rect.fromLTRB(0,0,200,200));
      // canvas.clipPath( path );
      
      canvas.drawImageRect( image, 
        Rect.fromLTWH(0,0,image.width.toDouble(),image.height.toDouble()), 
        Rect.fromLTWH(0,0,size.width,size.height), 
        paint );
    }
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate.image != this.image ? true : false;
  }


}



typedef ImageCallback = void Function( ui.Image image );

class ChildSnapshot extends StatelessWidget {
  final GlobalKey _globalKey = new GlobalKey();

  ChildSnapshot({Key key, this.child, this.onComplete}):super(key:key);
  final Widget child;
  final ImageCallback onComplete;

  void _renderSnapshot(){
    Future.delayed( Duration( milliseconds: 3000 ) ).then((result) async {
      //generate a snapshot
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      //var codec = await ui.instantiateMovieCodec(data.buffer.asUint8List());
      onComplete( image );
    });
  }

  @override
  Widget build(BuildContext context) {
    _renderSnapshot();
    return RepaintBoundary(
      key: _globalKey,
      child: child,
    );
  }
}

/*
class ImagePainter extends CustomPainter{
  ui.FrameInfo frame;
  ui.Image image;
  ImagePainter( this.frame ): super();

  @override
  void paint(ui.Canvas canvas, ui.Size size) {

    if( frame != null ){
      Paint paint = new Paint()
      ..colorFilter = ColorFilter.mode(Colors.orange, BlendMode.multiply);
      // TODO: implement paint

      // Path path = Path()
      // ..addRect(Rect.fromLTRB(0,0,200,200));
      // canvas.clipPath( path );
      
      canvas.drawImageRect( image, 
        Rect.fromLTWH(0,0,frame.image.width.toDouble(),frame.image.height.toDouble()), 
        Rect.fromLTWH(0,0,size.width,size.height), 
        paint );
    }
  }
}
*/

/*
class CompositedWidget extends StatefulWidget{
  _capture() async{
    RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      data = await image.toByteData(format: ui.ImageByteFormat.png);
      var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      //var codec = await ui.instantiateMovieCodec(data.buffer.asUint8List());
      frame = await codec.getNextFrame();

      final ByteData imageData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      
  }
}
*/


class ShaderComponent extends StatefulWidget {
  ShaderComponent({Key key, this.title}) : super(key: key);
  final String title;
  _ShaderComponentState createState() => _ShaderComponentState();
}

class _ShaderComponentState extends State<ShaderComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(color:Colors.red),
        child: SlideShow(children:[
          Container( child: Text("Child 1"), width: 100.0, height: 100.0, decoration: BoxDecoration( color: Colors.blue ) ),
          Container( child: Text("Child 2"), width: 100.0, height: 100.0, decoration: BoxDecoration( color: Colors.green ) ),
          Container( child: Text("Child 3"), width: 100.0, height: 100.0, decoration: BoxDecoration( color: Colors.red ) ),
        ])
      ),
    );
  }
}

class BoxEffect extends SingleChildRenderObjectWidget {
  /// Creates a widget that makes its child partially transparent.
  ///
  /// The [opacity] argument must not be null and must be between 0.0 and 1.0
  /// (inclusive).
  const BoxEffect({
    Key key,
    @required this.opacity,
    this.alwaysIncludeSemantics = false,
    Widget child,
  }) : assert(opacity != null && opacity >= 0.0 && opacity <= 1.0),
       assert(alwaysIncludeSemantics != null),
       super(key: key, child: child);

  /// The fraction to scale the child's alpha value.
  ///
  /// An opacity of 1.0 is fully opaque. An opacity of 0.0 is fully transparent
  /// (i.e., invisible).
  ///
  /// The opacity must not be null.
  ///
  /// Values 1.0 and 0.0 are painted with a fast path. Other values
  /// require painting the child into an intermediate buffer, which is
  /// expensive.
  final double opacity;

  /// Whether the semantic information of the children is always included.
  ///
  /// Defaults to false.
  ///
  /// When true, regardless of the opacity settings the child semantic
  /// information is exposed as if the widget were fully visible. This is
  /// useful in cases where labels may be hidden during animations that
  /// would otherwise contribute relevant semantics.
  final bool alwaysIncludeSemantics;

  @override
  RenderBoxEffect createRenderObject(BuildContext context) {
    return RenderBoxEffect(
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBoxEffect renderObject) {
    renderObject
      ..opacity = opacity
      ..alwaysIncludeSemantics = alwaysIncludeSemantics;
  }
}

class RenderBoxEffect extends RenderProxyBox {
  /// Creates a partially transparent render object.
  ///
  /// The [opacity] argument must be between 0.0 and 1.0, inclusive.
  RenderBoxEffect({
    double opacity = 1.0,
    bool alwaysIncludeSemantics = false,
    RenderBox child,
  }) : assert(opacity != null),
       assert(opacity >= 0.0 && opacity <= 1.0),
       assert(alwaysIncludeSemantics != null),
       _opacity = opacity,
       _alwaysIncludeSemantics = alwaysIncludeSemantics,
       _alpha = _getAlphaFromOpacity(opacity),
       super(child);

  @override
  bool get alwaysNeedsCompositing => true;

  int _alpha;

  /// The fraction to scale the child's alpha value.
  ///
  /// An opacity of 1.0 is fully opaque. An opacity of 0.0 is fully transparent
  /// (i.e., invisible).
  ///
  /// The opacity must not be null.
  ///
  /// Values 1.0 and 0.0 are painted with a fast path. Other values
  /// require painting the child into an intermediate buffer, which is
  /// expensive.
  double get opacity => _opacity;
  double _opacity;
  set opacity(double value) {
    assert(value != null);
    assert(value >= 0.0 && value <= 1.0);
    if (_opacity == value)
      return;
    final bool didNeedCompositing = alwaysNeedsCompositing;
    final bool wasVisible = _alpha != 0;
    _opacity = value;
    _alpha = _getAlphaFromOpacity(_opacity);
    if (didNeedCompositing != alwaysNeedsCompositing)
      markNeedsCompositingBitsUpdate();
    markNeedsPaint();
    if (wasVisible != (_alpha != 0))
      markNeedsSemanticsUpdate();
  }

  /// Whether child semantics are included regardless of the opacity.
  ///
  /// If false, semantics are excluded when [opacity] is 0.0.
  ///
  /// Defaults to false.
  bool get alwaysIncludeSemantics => _alwaysIncludeSemantics;
  bool _alwaysIncludeSemantics;
  set alwaysIncludeSemantics(bool value) {
    if (value == _alwaysIncludeSemantics)
      return;
    _alwaysIncludeSemantics = value;
    markNeedsSemanticsUpdate();
  }

  void _paintChildWithTransform(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      
      Paint paint = Paint()
      ..color = Color.fromARGB( 255, 0, 0, 255)
      ..blendMode = BlendMode.clear;


      //context.createChildContext(childLayer, bounds)
      //context.canvas.save();
      //context.pushClipRect(needsCompositing, offset, Rect.fromLTRB(0, 0, 100.0, 100.0), _paintChildWithTransform );
      //context.pushClipRect(needsCompositing, offset, Rect.fromLTRB(100, 100, 200.0, 200.0), _paintChildWithTransform );
      //context.paintChild(child, offset);
      context.canvas.drawOval(Rect.fromLTRB(0, 0, 200.0, 100.0), paint);
      //context.canvas.restore();
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null && (_alpha != 0 || alwaysIncludeSemantics))
      visitor(child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('opacity', opacity));
    properties.add(FlagProperty('alwaysIncludeSemantics', value: alwaysIncludeSemantics, ifTrue: 'alwaysIncludeSemantics'));
  }
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Container(
        width: 200,
        height: 200,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: AspectRatio(
                aspectRatio: 1.0, child: CameraPreview(controller))));
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pick Image Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new ShaderComponent(title: 'Pick Image Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with LoadingDelegate {
  String currentSelected = "";
  List<Uint8List> images = [];

  void _pickImage() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
      List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
      currentSelected = "${list.length}\r\n";
      images.clear();

      //What day is it today
      DateTime now = DateTime.now();
      DateTime today =
          DateTime.parse("${now.year}-0${now.month}-0${now.day} 00:00:00Z");
      print(today);

      list.forEach((AssetPathEntity item) async {
        if (item.name == 'Camera') {
          //this is effectively a list of directories/groups/containers of images
          List<AssetEntity> imageList = await item.assetList;

          for (AssetEntity asset in imageList) {
            File file = await asset.file;
            DateTime lastModified = await file.lastModified();
            //get

            if (lastModified.isAfter(today)) {
              currentSelected += "${item.name}-${asset.type}\r\n";
              Uint8List image = await asset.thumbDataWithSize(500, 500);
              images.add(image);
            } else {
              break;
            }
          }
        }
        setState(() {});
      });
    } else {
      PhotoManager.openSetting();
      // fail
      // if result is fail, you can call c;  to open android/ios applicaton's setting to get permission
    }
  }

  List<Widget> _buildImages() {
    var items = List<Widget>();

    images.forEach((Uint8List image) {
      items.add(Expanded(child: Image.memory(image)));
    });

    return items;
  }

  void _pickImageOld() async {
    List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      // BuildContext required
      context: context,

      /// The following are optional parameters.
      themeColor: Colors.orange,
      // the title color and bottom color
      padding: 1.0,
      // item padding
      dividerColor: Colors.grey,
      // divider color
      disableColor: Colors.grey.shade300,
      // the check box disable color
      itemRadio: 0.88,
      // the content item radio
      maxSelected: 8,
      // max picker image count
      provider: I18nProvider.english,
      // i18n provider ,default is chinese. , you can custom I18nProvider or use ENProvider()
      rowCount: 3,
      // item row count
      textColor: Colors.white,
      // text color
      thumbSize: 150,
      // preview thumb size , default is 64
      sortDelegate: SortDelegate.common,
      // default is common ,or you make custom delegate to sort your gallery
      checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
        activeColor: Colors.white,
        unselectedColor: Colors.white,
      ),
      // default is DefaultCheckBoxBuilderDelegate ,or you make custom delegate to create checkbox

      loadingDelegate: this,
      // if you want to build custom loading widget,extends LoadingDelegate, [see example/lib/main.dart]

      badgeDelegate: const DurationBadgeDelegate(),
    );

    if (imgList == null) {
      currentSelected = "not select item";
    } else {
      List<String> r = [];
      for (var e in imgList) {
        var file = await e.file;
        r.add(file.absolute.path);
      }
      currentSelected = r.join("\n\n");
    }
    setState(() {});
  }

  @override
  Widget buildBigImageLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  @override
  Widget buildPreviewLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
            Text(
              '$currentSelected',
              textAlign: TextAlign.center,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: _buildImages())
          ])),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'pickImage',
        child: new Icon(Icons.add),
      ),
    );
  }
}
