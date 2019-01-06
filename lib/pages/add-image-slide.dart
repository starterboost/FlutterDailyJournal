import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import '../elements/btn-cancel.dart';
import '../model/app-model.dart';
import 'package:scoped_model/scoped_model.dart';

class AddImageSlidePage extends StatefulWidget {
  @override
  AddImageSlidePageState createState() {
    return new AddImageSlidePageState();
  }
}

class AddImageSlidePageState extends State<AddImageSlidePage> {
  List<AssetEntity> _images = [];
  ScrollController _controller;
  Timer _scrollingEnabled;

  @override
  void initState() {
    //define the controller
    _controller = new ScrollController();
    
    _controller.addListener(() {
      if( _scrollingEnabled != null ){
        _scrollingEnabled.cancel();
      }

      setState((){
        _scrollingEnabled = Timer( Duration( milliseconds: 500 ), (){
          //completed
          setState((){
            _scrollingEnabled = null;
          });
        } );
      });
    });

    //call super
    super.initState();
    //do this separate
    _loadImages();
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
    
    if( _scrollingEnabled != null ){
      _scrollingEnabled.cancel();
      _scrollingEnabled = null;
    }

  }

  void _addImage( AssetEntity image ){
    if( mounted ){
      setState((){
        _images.add( image );
      });
    }
  }

  void _loadImages() async {
    var result = await PhotoManager.requestPermission();
    
    if (result) {
      // success
      List<AssetPathEntity> photoGroups = await PhotoManager.getAssetPathList();
      List<AssetEntity> images = [];
      DateTime now = DateTime.now();
      DateTime today =
          DateTime.parse("${now.year}-0${now.month}-0${now.day} 00:00:00Z");

      //print('StepA');
      for (AssetPathEntity photoGroup in photoGroups) {
        //this is effectively a list of directories/groups/containers of images
        //print('StepB: ${photoGroup.name}');
        if (photoGroup.name == "All Photos") {
          //print('StepB2');
          List<AssetEntity> imageList = await photoGroup.assetList;
          //print('StepC ${imageList.length}');
          int count = 0;
          for (AssetEntity asset in imageList) {
            //print('StepD');
            //check if the file is in range
            if (asset.type == AssetType.image) {
              File file = await asset.file;
              if (file != null) {
                //print('StepE');
                DateTime lastModified = await file.lastModified();
                //print("Date: $lastModified $today");
                //only add images that are from today
                if(lastModified.isAfter(today)) {
                  //if check we don't already have an image with that id
                  //print('StepG');

                  if (images.firstWhere((image) {
                        return image.id == asset.id ? true : false;
                      }, orElse: () {
                        return null;
                      }) ==
                      null) {
                    //file with that path doesn't exist
                    _addImage( asset );
                  }

                }
              }
            }
          }
        }
        /*

        */
      }
      
    } else {
      // fail
      throw ("Don't have permission to access Photos");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int numImagesPerRow = 3;
    double imageSize = width / numImagesPerRow;
    bool isScrolling = _scrollingEnabled == null ? false : true;
    
    //print("Build: ${_images.length}");
    return Scaffold(
        appBar: new AppBar(title: new Text("Select Image"), actions: [
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
        body: ScopedModelDescendant<AppModel>(
          builder: (context, child, model){

          return GridView.builder(
            controller: _controller,
            itemCount: _images.length + 1,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, index) {
              //print("itemBuilder $index");
              if (index == 0) {
                return Container(
                    decoration: BoxDecoration(color: Colors.purple),
                    child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/add-photo");
                        },
                        child: Center(
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt),
                                Text(
                                  "Take Photo",
                                  style: Theme.of(context).textTheme.headline,
                                )
                              ]),
                        )));
              } else {
                AssetEntity asset = _images[index - 1];
                return Container(
                    key: Key(asset.id),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 220, 220, 220)),
                    child: InkWell(
                        onTap: () async {
                          //add the photo
                          Uint8List data = await asset.thumbDataWithSize( 400, 400);
                          model.preview = ImageSlide( data: data );
                          Navigator.pushNamed(context, "/add-preview");
                        },
                        child: _ImageButton(asset: asset, enableFullAsset: !isScrolling)));
              }
            });
        }));
  }
}

class _ImageButton extends StatefulWidget {
  _ImageButton({Key key, @required this.asset, this.enableFullAsset = false});
  final AssetEntity asset;
  final bool enableFullAsset;

  __ImageButtonState createState() => __ImageButtonState();
}

class __ImageButtonState extends State<_ImageButton> {
  Uint8List _imageData;
  int _loadedSize = 0;

  @override
  initState() {
    super.initState();

    //load the thumbnail
    _loadImageData();
  }

  @override void didUpdateWidget(_ImageButton oldWidget) {
      // TODO: implement didUpdateWidget
      super.didUpdateWidget(oldWidget);
      //detect change of the enableFullAsset
      if( oldWidget.enableFullAsset != widget.enableFullAsset ){
        if( widget.enableFullAsset ){
          _loadImageData( size:100 );
        }
      }
  }

  void _loadImageData( {int size = 10} ) async {
    if( size > _loadedSize ){
      _loadedSize = size;
      _imageData = await widget.asset.thumbDataWithSize(size, size);
      //incase dispose has been called
      if (this.mounted) {
        setState(() {});
      } else {
        _imageData = null;
      }
    }

  }

  @override
  dispose() {
    super.dispose();
    _imageData = null;
  }

  @override
  Widget build(BuildContext context) {
    return _imageData == null
        ? Container( width: 10.0, height: 10.0, child: CircularProgressIndicator() )
        : Container(
            decoration: BoxDecoration(
              color: widget.enableFullAsset ? Colors.red : Colors.blue,
              border: Border.all(color:Colors.grey,width:0.5),
            ),
            padding: EdgeInsets.all(5.0),
            child: Image.memory(_imageData, fit: BoxFit.cover));
  }
}
