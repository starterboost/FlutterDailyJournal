import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:scoped_model/scoped_model.dart';
import 'package:photo_manager/photo_manager.dart';

String _dateToName( DateTime date ){
    return '${date.year}-${date.month}-${date.day}.json';
}

class AppModel extends Model {
  Storage _storage;
  Storage _storageImages;

  List<JournalEntry> _items = [];

  get items => _items;

  List<Uint8List> images = [];
  Slide _preview;

  Slide get preview => _preview;

  set preview( Slide slide ){
    _preview = slide;
    notifyListeners();
  }

  Future<void> init() async{
    _storage = new Storage("journal");
    _storage.init();

    _storageImages = new Storage("journal-images");
    _storageImages.init();

    print("init Model");
    //load all data
    Stream<FileSystemEntity> contentStream = await _storage.listContents();
    //listen for the contents
    contentStream.listen( (FileSystemEntity file) async {
      print("init Model file ${file.path}");
      String fileName = path.basename( file.path );
      print( fileName );
      try{
        Map<String, dynamic> data = await _storage.readFileAsJSON(fileName);
        if( !data.containsKey('date') ){
          throw 'Date missing from data';
        }

        //got to here - all must be fine
        print('fromJSON: $data');
        addEntry( JournalEntry.fromJson( data ) );
      }catch(err){
        print('Error opening the file: ${err}');
        //data malformed - delete (for now)
        //_storage.deleteFile( fileName );
      }
    });
  }

  Future<File> saveImage( List<dynamic> data, { String extension = "png"} ){
    DateTime dateNow = DateTime.now();
    String name = dateNow.millisecondsSinceEpoch.toString();
    return _storageImages.writeFileAsBytes("${name}.${extension}", data );
  }

  void addEntry( JournalEntry entry ) {
    // First, increment the counter
    _items.add( entry );
    print('Added entry');
    // Then notify all the listeners.
    notifyListeners();
  }
  
  void saveEntry( JournalEntry entry ) {
    print("saveEntry");
    // First, increment the counter
    if( _items.contains( entry ) ){
      _storage.writeFileAsJson( _dateToName( entry.date ), entry );
      print("savedEntry");
    }
    // Then notify all the listeners.
    notifyListeners();
  }

  void saveEntryForToday(){
    JournalEntry entry = getEntryForToday();
    if( entry != null ){
      saveEntry( entry );
    }
  }

  JournalEntry getEntryById( int id ){
    return _items.firstWhere((item){
      return item.id == id ? true : false;
    });
  }
  
  JournalEntry getEntryForToday( {bool createIfNull = false} ){
    DateFormat dateFormat = DateFormat.yMd();
    DateTime dateNow = DateTime.now();

    try{
      return _items.firstWhere((item){
        return dateFormat.format( dateNow ) == dateFormat.format( item.date ) ? true : false;
      });
    }catch(err){

    }

    return createIfNull ? createEntryForToday() : null;
  }

  JournalEntry createEntryForToday(){
    JournalEntry journal = JournalEntry( DateTime.now() );
    addEntry( journal );
    return journal;
  }
}


class JournalEntry{
  static int _id = 0;

  JournalEntry( this.date, {this.images} ){
    if( this.images == null ){
      this.images = [];
    }
  }

  final int id = _id++;
  List<String> images;
  final DateTime date;

  JournalEntry.fromJson(Map<String, dynamic> json):
    date = DateTime.parse(json['date']),
    images = []
  {
      for( var image in json['images'] ){
        if( image is String ){
          images.add( image );
        }

        print('Image: ${image}');
      }
  }
        //images = json['images'] as List<String>;

  Map<String, dynamic> toJson() =>
  {
    'images': images,
    'date': date.toString(),
  };
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



class Storage {
  final String dir;

  Storage( this.dir );

  init() async{
    Directory dir = await localDir;

    dir.create();
  }

  Future<String> get localDirPath async {
    final dir = await getApplicationDocumentsDirectory();
    return path.join( dir.path, this.dir );
  }

  Future<Directory> get localDir async {
    final dir = await localDirPath;
    return new Directory( dir );
  }

  Future<Stream<FileSystemEntity>> listContents() async {
    Directory dir = await localDir;
    print('listContents ${dir.path}');
    return dir.list(recursive:false,followLinks:false);
  }

  Future<File> getFile( name ) async {
    final dir = await localDirPath;
    return File('$dir/$name');
  }

  Future<String> readFileAsString( String name ) async {
    final file = await getFile(name);
    String body = await file.readAsString();
    return body;
  }

  Future<Map<String, dynamic>> readFileAsJSON( String name ) async{
    String contents = await readFileAsString( name );
    
    var data = json.decode( contents );
    if( data is Map<String, dynamic> ){
      return data;
    }else{
      throw 'Unable to parse data';
    }
  }

  Future<File> writeFileAsString( String name, String data) async {
    final file = await getFile(name);
    return file.writeAsString(data);
  }
  
  Future<File> writeFileAsJson( String name, dynamic data) async {
    return writeFileAsString(name, json.encode(data) );
  }
  
  Future<File> writeFileAsBytes( String name, List<dynamic> data ) async {
    final file = await getFile(name);
    return file.writeAsBytes( data );
  }

  Future<FileSystemEntity> deleteFile( String name ) async {
    final file = await getFile(name);
    return file.delete();
  }
}