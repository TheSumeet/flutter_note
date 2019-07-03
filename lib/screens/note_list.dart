import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'package:note/models/note.dart';
import 'package:note/utils/database_helper.dart';
import 'package:note/screens/note_detail.dart';
import 'note_detail.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;

  int itemCount = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'notes',
        ),
        elevation: 0,
      ),
      body: noteList.length == 0
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Press '),
                  Icon(Icons.add_circle),
                  Text(' icon to add note')

                ],
              ),
            )
          : getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'add note');
        },
        child: Icon(Icons.add),
        tooltip: 'add note',
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(
              this.noteList[position].title,
            ),
            subtitle: Text(this.noteList[position].date),
            trailing: GestureDetector(
              onTap: () {
                _deleteNote(context, this.noteList[position]);
              },
              child: Icon(
                Icons.delete,
                color: Colors.red,
                size: 30,
              ),
            ),
            onTap: () {
              navigateToDetail(this.noteList[position], 'edit note');
            },
          ),
        );
      },
    );
  }

  Future navigateToDetail(Note note, String title) async {
    await Navigator.push(context,
            MaterialPageRoute(builder: (context) => NoteDetail(note, title)))
        .then((value) {
      updateListView();
    });
  }

  //  Return priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.keyboard_arrow_right);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  //  Return priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
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
