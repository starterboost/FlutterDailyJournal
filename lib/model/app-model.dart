import 'package:scoped_model/scoped_model.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class AppModel extends Model {
  List<Uint8List> images = [];
  Slide _preview;

  Slide get preview => _preview;

  set preview( Slide slide ){
    _preview = slide;
    notifyListeners();
  }
}

class Slide{

}

class AssetEntitySlide extends Slide{
  AssetEntitySlide({this.asset});

  //final File file;
  final AssetEntity asset;
}

class ImageSlide extends Slide{
  ImageSlide({this.file});

  //final File file;
  final File file;
}

class TextSlide extends Slide{
  TextSlide({this.text, this.color});

  //final File file;
  String text;
  Color color;
}