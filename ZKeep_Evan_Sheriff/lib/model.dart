class Todo {
  Todo({required this.id, required this.name, this.checked = false});

  final int? id;
  final String name;
  bool checked;

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'checked': checked ? 1 : 0};
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(id: map['id'], name: map['name'], checked: map['checked'] == 1);
  }
}
