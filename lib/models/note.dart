class Note {
  int id;
  String body;
  String title;
  String updatedAt;
  Note({this.title, this.body, this.updatedAt});
  bool isChecked = false;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['body'] = body;
    map['updatedAt'] = updatedAt;
    return map;
  }

  Note.fromMap(dynamic data) {
    this.id = data['id'];
    this.title = data['title'];
    this.body = data['body'];
    this.updatedAt = data['updatedAt'];
  }
}
