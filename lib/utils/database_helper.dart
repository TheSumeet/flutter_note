import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:note/models/note.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;
  static Database _database;

  // Database structure
  String  noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {

    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  // Open the database
  Future<Database> initializeDatabase() async{
    // Get the directory path
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'note.db';

    // Open / create database at given path
    var noteDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return noteDatabase;
  }

  // SQL string to create the database
  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //  Fetch operation: get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db = await this.database;

    // var result = await db.rawQuery('SELECT * from $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;


  }

  //  Insert operation: insert a note object in database
  Future<int> insertNote(Note note) async{
    Database db = await this.database;
    int result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //  Update operation: update and save note object in database
  Future<int> updateNote(Note note) async{
    Database db = await this.database;
    int result = await db.update(noteTable, note.toMap(), where: '$colId', whereArgs: [note.id]);
    return result;
  }

  //  Delete operation: delete a note object from database
  Future<int> deleteNote(int id) async{
    Database db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  //  Get number of the note object from database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT count(*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Convert List<Map> to List<Note>
  Future<List<Note>> getNoteList() async {
    var mapList = await getNoteMapList();
    int count = mapList.length;

    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(mapList[i]));
    }

    return noteList;
  }

}