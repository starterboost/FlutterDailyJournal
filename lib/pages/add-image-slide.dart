import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'dart:typed_data';

import '../elements/btn-cancel.dart';

class AddImageSlidePage extends StatefulWidget {
  @override
  AddImageSlidePageState createState() {
    return new AddImageSlidePageState();
  }
}

class AddImageSlidePageState extends State<AddImageSlidePage> {
  List<AssetEntity> _images = [];
  ScrollController _controller;

  void _loadImages() async {
    print('Loading images');
    var result = await PhotoManager.requestPermission();
    print('Result $result');
    if (result) {
      print('Listing images');
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
                //only add images that are from today
                if (lastModified.isAfter(today)) {
                  //if check we don't already have an image with that id
                  //print('StepG');

                  if (images.firstWhere((image) {
                        return image.id == asset.id ? true : false;
                      }, orElse: () {
                        return null;
                      }) ==
                      null) {
                    //file with that path doesn't exist
                    images.add(asset);
                    setState((){});
                  }

                  if (count++ > 50) {
                    break;
                  }
                } else {
                  //we're breaking because we should receive files in date order - the rest in the list should be after today
                  break;
                }
              }
            }
          }
        }
        /*

        */
      }
      //call to update the images
      setState(() {
        _images = images;
      });
    } else {
      // fail
      throw ("Don't have permission to access Photos");
    }
  }

  @override
  void initState() {
    //define the controller
    _controller = new ScrollController();
    _controller.addListener(() {
      print('Scroll change');
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
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int numImagesPerRow = 3;
    double imageSize = width / numImagesPerRow;
    print("Build: ${_images.length}");
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
        body: GridView.builder(
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
                        onTap: () {
                          //add the photo
                          Navigator.pushNamed(context, "/add-preview");
                        },
                        child: _ImageButton(asset: asset)));
              }
            }));
  }
}

class _ImageButton extends StatefulWidget {
  _ImageButton({Key key, @required this.asset});
  final AssetEntity asset;

  __ImageButtonState createState() => __ImageButtonState();
}

class __ImageButtonState extends State<_ImageButton> {
  Uint8List _imageData;
  @override
  initState() {
    super.initState();

    //load the thumbnail
    _loadImageData();
  }

  void _loadImageData() async {
    _imageData = await widget.asset.thumbDataWithSize(10, 10);
    //incase dispose has been called
    if (this.mounted) {
      setState(() {});
    } else {
      _imageData = null;
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
              border: Border.all(color:Colors.grey,width:0.5),
            ),
            padding: EdgeInsets.all(5.0),
            child: Image.memory(_imageData, fit: BoxFit.cover));
  }
}
