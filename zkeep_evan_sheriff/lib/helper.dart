import 'package:zkeep_evan_sheriff/model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<Database> init() async {
    final String path = join(await getDatabasesPath(), 'zkeep.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        title TEXT    NOT NULL,
        color INTEGER NOT NULL DEFAULT ${0xFFFFFF99}
      );
    ''');
    await db.execute('''
      CREATE TABLE todos (
        id      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        note_id INTEGER NOT NULL,
        name    TEXT    NOT NULL,
        checked INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
      );
    ''');
  }

  static Future<Database> _open() async {
    final String path = join(await getDatabasesPath(), 'zkeep.db');
    return openDatabase(path, version: 1);
  }

  // ── Notes ──────────────────────────────────────────────────────────────────

  static Future<List<Note>> getNotes() async {
    final Database db = await _open();
    final List<Map<String, dynamic>> result = await db.query('notes');
    if (result.isEmpty) return <Note>[];
    return result.map((row) => Note.fromMap(row)).toList();
  }

  static Future<int> insertNote(Note note) async {
    final Database db = await _open();
    return await db.insert('notes', note.toMap()..remove('id'));
  }

  static Future<void> updateNote(Note note) async {
    final Database db = await _open();
    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  static Future<void> deleteNote(Note note) async {
    final Database db = await _open();
    // todos are deleted by cascade
    await db.delete('notes', where: 'id = ?', whereArgs: [note.id]);
  }

  // ── Todos ──────────────────────────────────────────────────────────────────

  static Future<List<Todo>> getTodosForNote(int noteId) async {
    final Database db = await _open();
    final List<Map<String, dynamic>> result = await db.query(
      'todos',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
    if (result.isEmpty) return <Todo>[];
    return result.map((row) => Todo.fromMap(row)).toList();
  }

  static Future<int> insertTodo(Todo todo) async {
    final Database db = await _open();
    return await db.insert('todos', todo.toMap()..remove('id'));
  }

  static Future<void> updateTodo(Todo todo) async {
    final Database db = await _open();
    await db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  static Future<void> deleteTodo(Todo todo) async {
    final Database db = await _open();
    await db.delete('todos', where: 'id = ?', whereArgs: [todo.id]);
  }
}
