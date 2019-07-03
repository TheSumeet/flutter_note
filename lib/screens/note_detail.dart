import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/block_picker.dart';

import 'package:note/models/note.dart';
import 'package:note/utils/database_helper.dart';
import 'package:note/utils/widgets.dart';

class NoteDetail extends StatefulWidget {
  final Note note;
  String appBarTitle;

  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() =>
      _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  String priority = 'select priority';
  static var _priorities = ['low', 'medium', 'high'];
  final Note note;
  int color;
  Color pickerColor;
  Color currentColor;
  bool isEdited = false;

  DatabaseHelper helper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    descriptionController.text = note.description;

    color = note.color;
    pickerColor = colors[color];
    currentColor = colors[color];

    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          isEdited ? showDiscardDialog(context) : moveToLastScreen();
        },
        child: Scaffold(
          backgroundColor: colors[color],
          appBar: AppBar(
            title: Text(
              'edit note',
              style: Theme.of(context).textTheme.headline,
            ),
            leading: IconButton(
              iconSize: 32,
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.black,
              onPressed: () {
                isEdited ? showDiscardDialog(context) : moveToLastScreen();
              },
            ),
            elevation: 0,
            backgroundColor: colors[color],
            actions: <Widget>[
              IconButton(
                tooltip: 'save',
                icon: Icon(
                  Icons.save,
                  color: Colors.black,
                  size: 32,
                ),
                onPressed: () {
                  _save();
                },
              ),
              IconButton(
                tooltip: 'change color',
                icon: Icon(
                  Icons.color_lens,
                  color: Colors.black,
                  size: 32,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          titlePadding: const EdgeInsets.all(0.0),
                          contentPadding: const EdgeInsets.all(0.0),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              availableColors: colors,
                              pickerColor: currentColor,
                              onColorChanged: changeColor,
                            ),
                          ),
                        );
                      });
                },
              ),
              IconButton(
                tooltip: 'delete note',
                icon: Icon(
                  Icons.delete,
                  color: Colors.black,
                  size: 32,
                ),
                onPressed: () {
                  _delete();
                },
              ),
            ],
          ),
          body: Container(
            color: colors[color],
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListTile(
                    title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(
                            dropDownStringItem,
                            style: Theme.of(context).textTheme.body2,
                          ),
                        );
                      }).toList(),
//                  style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (value) {
                        updatePriorityAsInt(value);
                        setState(() {});
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: titleController,
                    maxLength: 50,
                    style: Theme.of(context).textTheme.body1,
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'title',
                        labelStyle: Theme.of(context).textTheme.body2,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        )),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 20,
                      maxLength: 500,
                      controller: descriptionController,
                      style: Theme.of(context).textTheme.body2,
                      onChanged: (value) {
                        updateDescription();
                      },
                      decoration: InputDecoration(
                          labelText: 'description',
                          alignLabelWithHint: true,
                          labelStyle: Theme.of(context).textTheme.body2,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Convert string priority to integer before saving it to db
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'low':
        note.priority = 1;
        break;
      case 'medium':
        note.priority = 2;
        break;
      case 'high':
        note.priority = 3;
        break;
      default:
        note.priority = 2;
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
      case 3:
        priority = _priorities[2];
        break;
    }
    return priority;
    isEdited = true;
  }

  // Update the title
  void updateTitle() {
    note.title = titleController.text;
    isEdited = true;
  }

  // Update the description
  void updateDescription() {
    note.description = descriptionController.text;
    isEdited = true;
  }

  // Save data to database
  void _save() async {
    if(titleController.text != '') {
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
      } else {
        // Failed
        _showAlertDialog('status', 'problem saving note');
      }
    }else{
      _showAlertDialog('error', 'you must enter title');
    }
  }

  // Delet button
  void _delete() async {
    Navigator.pop(context, true);

    if (note.id == null) {
      // Note is not in database
//      _showAlertDialog('status', 'No note was deleted');
      return;
    }
    // Deleting note from database
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
//      _showAlertDialog('status', 'note deleted successfully');
    } else {
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

  void showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Discard Changes?",
            style: Theme.of(context).textTheme.body1,
          ),
          content: Text("Are you sure you want to discard changes ?",
              style: Theme.of(context).textTheme.body2),
          actions: <Widget>[
            FlatButton(
              child: Text("No",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Yes",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
                moveToLastScreen();
              },
            ),
          ],
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() {
      note.color = colors.indexOf(color);
      isEdited = true;
    });
  }
}
