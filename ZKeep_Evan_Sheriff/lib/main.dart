import 'package:zkeep_evan_sheriff/helper.dart';
import 'package:flutter/material.dart';

import 'model.dart';
import 'widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'am023 todo list floor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const MyHomePage(title: 'am023 todo list floor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textFieldController = TextEditingController();
  final List<Todo> _todos = <Todo>[];

  @override
  initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await DatabaseHelper.init();
    _updateTodos();
  }

  void _updateTodos() {
    DatabaseHelper.getTodos().then((todos) {
      setState(() {
        _todos.clear();
        _todos.addAll(todos);
      });
    });
  }

  void _handleTodoChange(Todo todo) {
    todo.checked = !todo.checked;
    setState(() {
      _todos.remove(todo);
      if (!todo.checked) {
        _todos.add(todo);
      } else {
        _todos.insert(0, todo);
      }
    });
    DatabaseHelper.updateTodo(todo);
  }

  void _handleTodoDelete(Todo todo) {
    setState(() {
      _todos.remove(todo);
    });
    DatabaseHelper.deleteTodo(todo);
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('add todo item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'type here ...'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _addTodoItem(String name) {
    Todo todo = Todo(id: null, name: name, checked: false);
    setState(() {
      _todos.insert(0, todo);
    });
    DatabaseHelper.insertTodo(todo);
    _textFieldController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: _todos.length,
          itemBuilder: (context, index) {
            return TodoItem(
              todo: _todos[index],
              onTodoChanged: _handleTodoChange,
              onTodoDelete: _handleTodoDelete,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }
}
