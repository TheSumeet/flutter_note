import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:note/models/note.dart';
import 'package:note/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final Note note;
  String appBarTitle;

  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['high', 'low'];
  final Note note;

  DatabaseHelper helper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String appBarTitle;
  String priority = 'select priority';

  _NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (value) {
                    updatePriorityAsInt(value);
                    setState(() {

                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: TextField(
                  maxLength: 30,
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: 'title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: TextField(
                  maxLines: 4,
                  maxLength: 1000,
                  expands: false,
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(16.0),
                        elevation: 0,
                        colorBrightness: Brightness.light,
                        color: Theme.of(context).buttonColor,
                        onPressed: () {
                          setState(() {
                            _save();
                          });
                        },
//                        color: Theme.of(context).primaryColorDark,
                        child: Text(
                          'save',
                          textScaleFactor: 1.5,
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(16.0),
                        elevation: 0,
                        colorBrightness: Brightness.light,
                        color: Colors.redAccent,
                        onPressed: (){
                          _delete();
                        },
                        child: Text(
                          'delete',
                          textScaleFactor: 1.5,
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Convert string priority to integer before saving it to db
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'high':
        note.priority = 1;
        break;
      case 'low':
        note.priority = 2;
        break;
    }
  }

  // Convert integer priority to string
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  // Update the title
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    Navigator.pop(context, true);

    int result;
    note.date = DateFormat.yMMMd().format(DateTime.now());
    if (note.id != null) {
      // Updating
      result = await helper.updateNote(note);
    } else {
      // Inserting
      result = await helper.insertNote(note);
    }

    if (result != 0) {
//      _showAlertDialog('status', 'note saved successfully');
    } else {
      // Failed
      _showAlertDialog('status', 'problem saving note');
    }
  }

  // Delet button
  void _delete() async {
    Navigator.pop(context, true);

    if(note.id == null) {   // Note is not in database
//      _showAlertDialog('status', 'No note was deleted');
      return;
    }
    // Deleting note from database
    int result = await helper.deleteNote(note.id);
    if(result != 0){
//      _showAlertDialog('status', 'note deleted successfully');
    }
    else{
      _showAlertDialog('status', 'Error occured while deleting note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }


}
