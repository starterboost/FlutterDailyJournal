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
  bool _isLoading = false;
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
    setState((){
      _isLoading = true;
    });

    var result = await PhotoManager.requestPermission();
    
    if (result) {
      // success
      List<AssetPathEntity> photoGroups = await PhotoManager.getAssetPathList(hasAll:false, hasVideo: false);
      List<AssetEntity> images = [];
      DateTime now = DateTime.now();
      //iOS puts all images in a temp directory which means they are all fresh and the modified date is useless
      DateTime today =
          DateTime.parse("${now.year}-0${now.month}-0${now.day} 00:00:00Z");

      //print('StepA');
      for (AssetPathEntity photoGroup in photoGroups) {
        //this is effectively a list of directories/groups/containers of images
        //only do this on iOS
        try{
          if (photoGroup.name == "All Photos") {
            //get the asssets within that directory
            List<AssetEntity> imageList = await photoGroup.assetList;
            for (AssetEntity asset in imageList) {
              //check if the file is in range
              if (asset.type == AssetType.image) {
                File file = await asset.file;
                if (file != null) {
                  //only add images that are from today
                  DateTime lastModified = await file.lastModified();
                  if(lastModified.isAfter(today)) {
                    //if check we don't already have an image with that id
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
        }catch( err ){

        }
      }
      
    } else {
      // fail
      throw ("Don't have permission to access Photos");
    }

    setState((){
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            itemCount: _images.length + 1 + (_images.length == 0 && _isLoading ? 1 : 0),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, index) {
              //print("itemBuilder $index");
              if (index == 0) {
                return Container(
                    decoration: BoxDecoration(color: Color.fromARGB(255, 200, 200, 200)),
                    child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/add-photo");
                        },
                        child: Center(
                          child:
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt),
                                Text(
                                  "Take Photo",
                                  style: TextStyle(fontSize:14.0),
                                )
                              ]),
                        )));
              } else if( _images.length == 0 && _isLoading && index == 1 ){
                return Container( width: 10.0, height: 10.0, child: CircularProgressIndicator() );
              } else {
                AssetEntity asset = _images[index - 1];
                return Container(
                    key: Key(asset.id),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 220, 220, 220)),
                    child: InkWell(
                        onTap: () async {
                          //add the photo
                          model.preview = AssetEntitySlide( asset: asset );
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
      //detect change of the enableFullAsset
      if( oldWidget.enableFullAsset != widget.enableFullAsset ){
        if( widget.enableFullAsset ){
          _loadImageData( size:100 );
        }
      }
      //did update widget
      super.didUpdateWidget(oldWidget);
  }

  void _loadImageData( {int size = 10} ) async {
    if( size > _loadedSize ){
      _loadedSize = size;
      _imageData = await widget.asset.thumbDataWithSize(size, size);
      //incase dispose has been called
      if (this.mounted) {
        setState(() {});
        if( widget.enableFullAsset ){
          _loadImageData( size:100 );
        }
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
