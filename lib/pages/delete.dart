import 'package:flutter/material.dart';
import 'package:sqlite_demo/database/database_helper.dart';
import 'package:sqlite_demo/models/note.dart';

class Delete extends StatefulWidget {
  final Function getData, showMsg;

  const Delete(this.getData, this.showMsg);
  @override
  _DeleteState createState() => _DeleteState(getData, showMsg);
}

class _DeleteState extends State<Delete> {
  final Function getData, showMsg;
  List<Note> notes = [];
  var db = DatabaseHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool checkBoxValue = false;
  bool okButton = true;
  String selectText = "Select all";

  _DeleteState(this.getData, this.showMsg);

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('My Notes'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 18),
              )),
          FlatButton(
            onPressed: notes.length == 0
                ? null
                : () {
                    setState(() {
                      selectText =
                          checkBoxValue ? "Select all" : "Unselect all";
                      okButton = checkBoxValue;
                      notes.forEach((note) {
                        note.isChecked = !checkBoxValue;
                      });
                      checkBoxValue = !checkBoxValue;
                    });
                  },
            child: Text(
              selectText,
              style: TextStyle(
                  color: notes.length == 0 ? Colors.grey[400] : Colors.white,
                  fontSize: 18),
            ),
          ),
          FlatButton(
            onPressed: okButton ? null : _deleteNote,
            child: Text(
              'Ok',
              style: TextStyle(
                  color: okButton ? Colors.grey[400] : Colors.white,
                  fontSize: 18),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        notes[index].title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      Text(
                        notes[index].body.length <= 30
                            ? notes[index].body
                            : notes[index].body.substring(0, 30) + '...',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black45,
                            letterSpacing: 0.25),
                      )
                    ],
                  )),
                  Checkbox(
                      value: notes[index].isChecked,
                      onChanged: (newValue) {
                        checkBoxValue = true;
                        okButton = true;
                        setState(() {
                          notes[index].isChecked = newValue;
                          notes.forEach((note) {
                            if (!note.isChecked) {
                              checkBoxValue = false;
                            }
                            if (note.isChecked) {
                              okButton = false;
                            }
                          });
                          selectText =
                              checkBoxValue ? "Unselect all" : "Select all";
                        });
                      })
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteNote() async {
    if (checkBoxValue) {
      await db.deleteAllNote();
    } else {
      List<int> ids = [];
      notes.forEach((note) {
        if (note.isChecked) {
          ids.add(note.id);
        }
      });
      await db.deleteMultipleNote(ids);
    }
    Navigator.pop(context);
    getData();
    showMsg("Note deleted");
  }

  void getNotes() async {
    var result = await db.getAllNotes();
    notes = result.map((note) => Note.fromMap(note)).toList();
    setState(() {});
  }
}
