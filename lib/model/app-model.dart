import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:scoped_model/scoped_model.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:sqflite/sqflite.dart';

String _dateToName( DateTime date ){
    return '${date.year}-${date.month}-${date.day}.json';
}

const String TABLE_JOURNAL_ENTRIES = "JournalEntries";
const String TABLE_IMAGES = "Images";

const String COLUMN_ID = "id";
const String COLUMN_IMAGE = "image";
const String COLUMN_JOURNAL_ID = "journalId";
const String COLUMN_DATE = "date";
class AppModel extends Model {

  Database _db;
  
  List<JournalEntry> _items = [];
  get items => _items;

  Slide _preview;


  Slide get preview => _preview;

  set preview( Slide slide ){
    _preview = slide;
    notifyListeners();
  }

  Future<void> init() async{

    var databasesPath = await getDatabasesPath();
    String dbPath = path.join(databasesPath, 'demo.db');

    // Delete the database
    await deleteDatabase(dbPath);

    File file = File( dbPath );
    bool fileExists = await file.exists();
    int fileSize = fileExists ? await file.length() : 0;

    print("init Model: $dbPath $fileSize");

    _db = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {

      print("created db");
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE $TABLE_JOURNAL_ENTRIES ($COLUMN_ID INTEGER PRIMARY KEY, $COLUMN_DATE TEXT)');
      await db.execute(
          'CREATE TABLE $TABLE_IMAGES ($COLUMN_ID INTEGER PRIMARY KEY, $COLUMN_IMAGE BLOB, $COLUMN_JOURNAL_ID INTEGER)');

      
      List<Map> dbJournalEntries = await db.rawQuery('SELECT * FROM $TABLE_JOURNAL_ENTRIES');
      print("$TABLE_JOURNAL_ENTRIES: ${dbJournalEntries.length}");
      List<Map> dbImages = await db.rawQuery('SELECT $COLUMN_ID, $COLUMN_JOURNAL_ID FROM $TABLE_IMAGES');

      print("$TABLE_IMAGES: ${dbImages.length}");

      //populate the items from the dbJournalEntries
      for( Map<String, dynamic> dbJournalEntry in dbJournalEntries ){
        JournalEntry item = JournalEntry.fromJson( dbJournalEntry );
        //get all the image ids
        dbImages.forEach(( dbImage ){
          print("${dbImage[COLUMN_JOURNAL_ID]} == ${item.id}");
          if( dbImage[COLUMN_JOURNAL_ID] == item.id ){
            item.images.add( dbImage[COLUMN_ID] );
          }
        });

        _items.add( item );
        //get all the images
      }

      notifyListeners();
    });

  }

  Future<int> addEntryImage( JournalEntry entry, List<dynamic> data ) async {
    //return the id of the image saved
    int imageId = await _db.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO $TABLE_IMAGES($COLUMN_JOURNAL_ID,$COLUMN_IMAGE) VALUES(?,?)', [entry.id, data]);
    });

    entry.images.add( imageId );

    notifyListeners();
  }

  Future <Uint8List> loadImage( int id ) async{
    List<Map<String, dynamic>> results = await _db.rawQuery('SELECT $COLUMN_IMAGE FROM $TABLE_IMAGES WHERE id=?',[id]);

    if( results.length > 0 ){
      Map<String, dynamic> result = results[0];
      return result["image"] as Uint8List;
    }

    return null;
  }


  Future<void> addEntry( JournalEntry entry ) async {
    // First, increment the counter
    _items.add( entry );
    entry.id = await _db.insert( TABLE_JOURNAL_ENTRIES, entry.toJson() );
    // Then notify all the listeners.
    notifyListeners();
  }
  
  JournalEntry getEntryById( int id ){
    return _items.firstWhere((item){
      return item.id == id ? true : false;
    });
  }
  
  JournalEntry getEntryForToday(){
    DateFormat dateFormat = DateFormat.yMd();
    DateTime dateNow = DateTime.now();
    String strToday = dateFormat.format( dateNow );

    try{
      return _items.firstWhere((item){
        return strToday == dateFormat.format( item.date ) ? true : false;
      });
    }catch(err){

    }

    return null;
  }

  Future<JournalEntry> createEntryForToday() async {
    JournalEntry journal = JournalEntry( date: DateTime.now() );
    await addEntry( journal );
    return journal;
  }
}


class JournalEntry{
  
  JournalEntry( {this.id, this.date, this.images} ){
    if( this.images == null ){
      this.images = [];
    }
  }

  int id = -1;
  List<int> images;
  final DateTime date;

  JournalEntry.fromJson(Map<String, dynamic> json):
    id = json[COLUMN_ID],
    date = DateTime.parse(json[COLUMN_DATE]),
    images = [];

  Map<String, dynamic> toJson() =>
  {
    //'images': images,
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
    bool exists = await dir.exists();
    
    if( !exists ){
      print("Creating ${dir.path}");
      dir.create();
    }else{
      print("Exists ${dir.path}");
    }
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
    file.writeAsBytes( data );
    return file;
  }

  Future<FileSystemEntity> deleteFile( String name ) async {
    final file = await getFile(name);
    return file.delete();
  }
}