class Note {
  Note({required this.id, required this.title, this.color = 0xFFFFFF99});

  final int? id;
  final String title;
  final int color;

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'color': color};
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      color: map['color'],
    );
  }

  Note copyWith({int? id, String? title, int? color}) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
    );
  }
}

class Todo {
  Todo({
    required this.id,
    required this.noteId,
    required this.name,
    this.checked = false,
  });

  final int? id;
  final int noteId;
  final String name;
  bool checked;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'name': name,
      'checked': checked ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      noteId: map['note_id'],
      name: map['name'],
      checked: map['checked'] == 1,
    );
  }
}
