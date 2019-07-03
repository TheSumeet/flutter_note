import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:note/models/note.dart';
import 'package:note/utils/database_helper.dart';
import 'package:note/screens/note_detail.dart';
import 'note_detail.dart';
import 'package:note/utils/widgets.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int itemCount = 0;
  int axisCount = 4;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'notes',
            style: Theme.of(context).textTheme.headline,
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              tooltip: 'add note',
              icon: Icon(
                Icons.add,
                color: Colors.black,
                size: 32,
              ),
              onPressed: () {
                navigateToDetail(Note('', '', 2, 0), 'add note');
              },
            ),
          ],
        ),
        body: noteList.length == 0
            ? Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('click on the add button to add a new note!',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.body1),
                  ),
                ),
              )
            : Container(
                color: Colors.white,
                child: getNotesList(),
              ),
      ),
    );
  }

  Widget getNotesList() {
    return StaggeredGridView.countBuilder(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
            onTap: () {
              navigateToDetail(this.noteList[index], 'Edit Note');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: colors[this.noteList[index].color],
//                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0)),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              this.noteList[index].title,
                              style: Theme.of(context).textTheme.body1,
                            ),
                          ),
                        ),
                        getPriorityIcon(this.noteList[index].priority),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              this.noteList[index].description == null
                                  ? ''
                                  : this.noteList[index].description,
                              style: Theme.of(context).textTheme.body2,
                              maxLines: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(this.noteList[index].date,
                              style: Theme.of(context).textTheme.subtitle),
                        ])
                  ],
                ),
              ),
            ),
          ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));

    if (result == true) {
      updateListView();
    }
  }

  //  Return priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.error, color: Colors.green,);
        break;
      case 2:
        return Icon(Icons.error, color: Colors.yellow,);
        break;
      case 3:
        return Icon(Icons.error, color: Colors.red,);
        break;
    }
  }

  // Delete note
  Future _deleteNote(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'note deleted successfully');
      updateListView();
    }
  }

  // Snackbar
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.itemCount = noteList.length;
        });
      });
    });
  }
}
