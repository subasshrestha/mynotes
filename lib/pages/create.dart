import 'package:flutter/material.dart';
import 'package:sqlite_demo/models/note.dart';
import 'package:sqlite_demo/database/database_helper.dart';

class Create extends StatefulWidget {
  final Function getData, showMsg;
  final int id;
  Create(this.getData, this.showMsg, {this.id});
  @override
  _CreateState createState() => _CreateState(getData, showMsg, id);
}

class _CreateState extends State<Create> {
  var db = DatabaseHelper();
  final Function getData, showMsg;
  int id;
//  List menuItems = ["Save", "Discard"];
  TextEditingController textController = TextEditingController();
  int len = 0;
  String time;
  Note note = Note();
  TextEditingController titleController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _CreateState(this.getData, this.showMsg, this.id) {
    if (id != null) {
      getNote(id);
    }
    note.updatedAt = DateTime.now().toString();
    time = note.updatedAt.toString().substring(0, 19);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Container(
              child: TextField(
                autofocus: true,
                maxLength: 50,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                controller: titleController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Edit title',
                    hintStyle: TextStyle(color: Colors.grey[350]),
                    counter: SizedBox.shrink()),
                cursorColor: Colors.white,
                onSubmitted: (text) {
                  FocusScope.of(context).requestFocus(focusNode);
                },
              ),
            ),
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: _save),
//              PopupMenuButton(
//                onSelected: (item){_select(item);},
//                itemBuilder: (context) =>
//                    menuItems.map((item) =>
//                        PopupMenuItem(value: item, child: Text(item))).toList(),
//              )
            ],
          ),
          body: Scrollbar(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text('$len/5000'),
                      ),
                      Text(time ?? ''),
                    ],
                  ),
                  TextField(
                    focusNode: focusNode,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    onChanged: (text) {
                      setState(() {
                        len = text.length;
                      });
                    },
                    maxLength: 5000,
                    cursorWidth: 1,
                    cursorColor: Colors.black45,
                    controller: textController,
                    textAlign: TextAlign.justify,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Type your note here",
                      border: InputBorder.none,
                      counter: SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void getNote(int id) async {
    note = await db.getNote(this.id);
    textController.text = note.body;
    titleController.text = note.title;
    note.updatedAt = DateTime.now().toString();
    len = note.body.length;
    setState(() {});
  }

  void _save() async {
    if (titleController.text.isNotEmpty || textController.text.isNotEmpty) {
      if (id != null) {
        note.title = titleController.text;
        note.body = textController.text;
        await db.updateNote(note);
      } else {
        await db.saveNote(Note(
            title: titleController.text,
            body: textController.text,
            updatedAt: note.updatedAt));
      }
      getData();
      showMsg("Note Saved");
    } else {
      showMsg("Note not Saved");
    }
    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    bool exit = false;
    if (titleController.text.isNotEmpty || textController.text.isNotEmpty) {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text('Exit'),
                content: Text('Do you Want to save this note ?'),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      exit = true;
                      if (id != null) {
                        note.title = titleController.text;
                        note.body = textController.text;
                        print(note.updatedAt);
                        db.updateNote(note);
                      } else {
                        db.saveNote(Note(
                            title: titleController.text,
                            body: textController.text,
                            updatedAt: note.updatedAt));
                      }
                      getData();
                      showMsg("Note Saved");
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      exit = true;
                    },
                  )
                ],
              ));
    } else {
      exit = true;
    }
    return Future.value(exit);
  }
}
