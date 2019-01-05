import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../elements/btn-cancel.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';

class AddImageSlidePage extends StatelessWidget {

  Future<List<AssetEntity>> _loadImages() async{
    print('Loading images');
    var result = await PhotoManager.requestPermission();
    print('Result $result');
    if (result) {
      print('Listing images');
      // success
      List<AssetPathEntity> photoGroups = await PhotoManager.getAssetPathList();
      List<AssetEntity> images = [];
      DateTime now = DateTime.now();
      DateTime today = DateTime.parse("${now.year}-0${now.month}-0${now.day} 00:00:00Z");
      
      for (AssetPathEntity photoGroup in photoGroups) {
        //this is effectively a list of directories/groups/containers of images
        List<AssetEntity> imageList = await photoGroup.assetList;

        for (AssetEntity asset in imageList) {
          //check if the file is in range
          File file = await asset.file;
          DateTime lastModified = await file.lastModified();
          //only add images that are from today
          if( lastModified.isAfter(today) ) {
            //if check we don't already have an image with that id
            if( images.firstWhere( (image){
              return image.id == asset.id ? true : false;
            }, orElse: (){return null;} ) == null ){
              images.add( asset );
              //file with that path doesn't exist
            }
          } else {
            //we're breaking because we should receive files in date order - the rest in the list should be after today
            break;
          }
        }
      }

      print('Images ${images.length}');
      return images;
    } else {
        // fail
        print("Images");
        throw("Don't have permission to access Photos");
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: FutureBuilder(
            future: _loadImages(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Error loading data...\n '${snapshot.error}'");
              } else if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                List<AssetEntity> assets = snapshot.data as List<AssetEntity>;
                print( assets.length );
                return GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this would produce 2 rows.
                  crossAxisCount: 3,
                  // Generate 100 Widgets that display their index in the List
                  children: List.generate( assets.length + 1, (index) {
                    if( index == 0 ){
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.purple
                            ),
                        child: InkWell(
                            onTap: () {
                              print("Selected child $index");
                              Navigator.pushNamed(context, "/add-preview");
                            },
                            child: Center(
                              child: Text(
                                "Take Photo",
                                style: Theme.of(context).textTheme.headline,
                              ),
                            )));
                    }else{
                      AssetEntity asset = assets[index - 1];
                      return Container(
                          decoration: BoxDecoration(
                              color: [
                            Colors.red,
                            Colors.blue,
                            Colors.green,
                            Colors.yellow
                          ][index % 4]),
                          child: InkWell(
                              onTap: () {
                                print("Selected child $index");
                                Navigator.pushNamed(context, "/add-preview");
                              },
                              child: Center(
                                child: Text(
                                  asset.id,
                                  style: Theme.of(context).textTheme.headline,
                                ),
                              )));
                    }
                  }),
                );
              }
            }));
  }
}

class _AddImageSlideButton extends StatelessWidget {
  _AddImageSlideButton({Key key, this.text, @required this.onPressed})
      : super(key: key);
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 200.0,
        decoration: BoxDecoration(color: Colors.red),
        child: Center(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(Icons.add),
            Container(width: 10),
            Text(this.text)
          ]),
        )),
      ),
    );
  }
}
