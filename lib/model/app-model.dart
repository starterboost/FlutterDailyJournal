import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';
import 'dart:typed_data';

class AppModel extends Model {
  Slide _preview;

  Slide get preview => _preview;

  set preview( Slide slide ){
    _preview = slide;
    notifyListeners();
  }
}

class Slide{

}

class ImageSlide extends Slide{
  ImageSlide({this.data});

  //final File file;
  final Uint8List data;
}