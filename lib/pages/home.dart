import 'package:flutter/material.dart';
import 'package:sqlite_demo/database/database_helper.dart';
import 'package:sqlite_demo/pages/create.dart';
import 'package:sqlite_demo/pages/delete.dart';
import 'package:share/share.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List notes=[];
  var db = DatabaseHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List menuItems = ["Delete", "Delete All", "About"];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('My Notes'),
        actions: <Widget>[
        PopupMenuButton(
                onSelected: _selectMenuItem,
                itemBuilder: (context) =>
                    menuItems.map((item) =>
                        PopupMenuItem(value: item, child: Text(item))).toList(),
              )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context)=>Create(getData,showMsg)
                )
            );
          },
          child: Icon(Icons.add),
          ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Card(
              child: InkWell(
                onTap: ()=>_selectListItem(notes[index]['id']),
                onLongPress: (){
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context)=>AlertDialog(
                      title: notes[index]['title'].toString().isEmpty?null:Text(notes[index]['title'].toString()),
                      content: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          ListTile(
                            title: Text('Share'),
                            onTap: (){
                              Navigator.of(context).pop();
                              Share.share('Title:${notes[index]['title']},Body:${notes[index]['body']}');
                            },
                          ),
                          ListTile(
                            title: Text('Delete'),
                            onTap: (){
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context)=>AlertDialog(
                                    title: Text('Delete'),
                                    content: Text('Are you sure to delete ?'),
                                    actions: <Widget>[
                                      Builder(
                                        builder: (context)=> FlatButton(
                                          child: const Text('Yes'),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await db.deleteNote(notes[index]['id']);
                                            notes = await db.getAllNotes();
                                            setState((){});
                                            showMsg("Note deleted");
                                          },
                                        ),
                                      ),
                                      FlatButton(
                                        child: const Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  )
                              );
                            },
                          )
                        ],
                      ),

                    )
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          notes[index]['title'].toString().isEmpty?SizedBox.shrink():Text(notes[index]['title'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black),),
                          Text(notes[index]['body'].length<=30?notes[index]['body']:notes[index]['body'].substring(0,30)+'...',style: TextStyle(fontSize: 16,color: Colors.black45,letterSpacing: 0.25),)
                        ],
                      )),
                      Column(
                        children: <Widget>[
                          Text(notes[index]['updatedAt'].toString().split(' ')[0]),
                          Text(notes[index]['updatedAt'].toString().split(' ')[1].substring(0,8)),
                        ],
                      )
                    ],
                  ),
                )
              ),
//            margin: EdgeInsets.only(bottom: ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> onWillPop() async {
    bool exit=false;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context)=>AlertDialog(
          title: Text('Exit'),
          content: Text('Are you sure to exit ?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Yes'),
              onPressed: (){
                exit=true;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('No'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
    return exit;
  }

  void _selectListItem(int id){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context)=>Create(getData,showMsg,id: id)
        )
    );
  }

  void getData() async{
    notes= await db.getAllNotes();
    setState((){});
  }

  void showMsg(String msg){
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 1),
    ));
  }

  void _selectMenuItem(item) async{
    if(item == "Delete"){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context)=>Delete(getData,showMsg)
          )
      );
    }
    else if(item == "Delete All"){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context)=>AlertDialog(
            title: Text('Delete'),
            content: Text('Are you sure to delete all notes?'),
            actions: <Widget>[
              Builder(
                builder: (context)=> FlatButton(
                  child: const Text('Yes'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await db.deleteAllNote();
                    getData();
                    showMsg("All notes deleted");
                  },
                ),
              ),
              FlatButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          )
      );
    }else if(item == "About"){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context)=>AlertDialog(
            title: Text('About Us'),
            content: Text('My Notes is a simple app where you can save your notes. This is created by Subas Shrestha.'),
            actions: <Widget>[
              Builder(
                builder: (context)=> FlatButton(
                  child: const Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          )
      );
    }
  }
}
