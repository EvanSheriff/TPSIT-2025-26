import 'package:flutter/material.dart';
import 'package:zkeep_evan_sheriff/helper.dart';
import 'package:zkeep_evan_sheriff/model.dart';
import 'package:zkeep_evan_sheriff/widgets.dart';

void main() {
  runApp(const ZKeepApp());
}

// ── App ────────────────────────────────────────────────────────────────────

class ZKeepApp extends StatelessWidget {
  const ZKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZKeep',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ── HomeScreen ─────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  // cache dei todo per ogni nota (note_id -> lista todo)
  final Map<int, List<Todo>> _todosMap = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await DatabaseHelper.init();
    await _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await DatabaseHelper.getNotes();
    final Map<int, List<Todo>> todosMap = {};
    for (final note in notes) {
      if (note.id != null) {
        todosMap[note.id!] = await DatabaseHelper.getTodosForNote(note.id!);
      }
    }
    setState(() {
      _notes = notes;
      _todosMap.clear();
      _todosMap.addAll(todosMap);
    });
  }

  Future<void> _showAddNoteDialog() async {
    final TextEditingController titleController = TextEditingController();
    int selectedColor = kNoteColors[0];

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Nuova nota'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(hintText: 'Titolo della nota'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Colore'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: kNoteColors.map((c) {
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == c
                                  ? Colors.black87
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    Navigator.of(ctx).pop();
                    final note = Note(
                        id: null, title: title, color: selectedColor);
                    final id = await DatabaseHelper.insertNote(note);
                    setState(() {
                      final newNote = note.copyWith(id: id);
                      _notes.add(newNote);
                      _todosMap[id] = [];
                    });
                  },
                  child: const Text('Aggiungi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteNote(Note note) async {
    await DatabaseHelper.deleteNote(note);
    setState(() {
      _notes.remove(note);
      if (note.id != null) _todosMap.remove(note.id);
    });
  }

  Future<void> _openNote(Note note) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(note: note),
      ),
    );
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZKeep'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text(
                'Nessuna nota.\nPremi + per aggiungerne una!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: _notes.length,
                itemBuilder: (_, index) {
                  final note = _notes[index];
                  final todos = _todosMap[note.id] ?? [];
                  return NoteCard(
                    note: note,
                    todos: todos,
                    onTap: () => _openNote(note),
                    onDelete: () => _deleteNote(note),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        tooltip: 'Aggiungi nota',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── NoteDetailScreen ───────────────────────────────────────────────────────

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, required this.note});

  final Note note;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await DatabaseHelper.getTodosForNote(widget.note.id!);
    setState(() {
      _todos
        ..clear()
        ..addAll(todos);
    });
  }

  Future<void> _addTodo() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final todo = Todo(id: null, noteId: widget.note.id!, name: name);
    final id = await DatabaseHelper.insertTodo(todo);
    setState(() {
      _todos.insert(
          0, Todo(id: id, noteId: widget.note.id!, name: name));
    });
    _controller.clear();
  }

  Future<void> _toggleTodo(Todo todo) async {
    todo.checked = !todo.checked;
    await DatabaseHelper.updateTodo(todo);
    setState(() {});
  }

  Future<void> _deleteTodo(Todo todo) async {
    await DatabaseHelper.deleteTodo(todo);
    setState(() => _todos.remove(todo));
  }

  Future<void> _showAddDialog() async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nuovo promemoria'),
          content: TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: 'Scrivi un promemoria...'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _addTodo();
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.note.color),
      appBar: AppBar(
        backgroundColor: Color(widget.note.color),
        title: Text(widget.note.title),
        elevation: 0,
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text(
                'Nessun promemoria.\nPremi + per aggiungerne uno!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            )
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (_, i) => TodoItem(
                todo: _todos[i],
                onChanged: () => _toggleTodo(_todos[i]),
                onDelete: () => _deleteTodo(_todos[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Aggiungi promemoria',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
