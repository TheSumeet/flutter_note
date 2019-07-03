import 'package:flutter/material.dart';
import 'package:note/screens/note_detail.dart';

import 'package:note/screens/note_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'note',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: NoteList(),
    );
  }
}
