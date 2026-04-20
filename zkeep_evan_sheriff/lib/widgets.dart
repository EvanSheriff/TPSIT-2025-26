import 'package:flutter/material.dart';
import 'model.dart';


const List<int> kNoteColors = [
  0xFFFFFF99,
  0xFFB9F6CA,
  0xFFBBDEFB,
  0xFFFFCCBC,
  0xFFE1BEE7,
  0xFFFFF9C4,
  0xFFB2EBF2,
  0xFFFFE0B2,
];



class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.todos,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final List<Todo> todos;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Color(note.color);
    // preview: max 3 todo
    final List<Todo> preview = todos.take(3).toList();
    final int remaining = todos.length - preview.length;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (preview.isNotEmpty) const SizedBox(height: 6),
              ...preview.map(
                (todo) => Row(
                  children: [
                    Icon(
                      todo.checked
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        todo.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          decoration: todo.checked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (remaining > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ altri $remaining',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TodoItem ───────────────────────────────────────────────────────────────

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: onChanged,
        child: Icon(
          todo.checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        todo.name,
        style: TextStyle(
          decoration: todo.checked ? TextDecoration.lineThrough : null,
          color: todo.checked ? Colors.black45 : Colors.black87,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: onDelete,
      ),
    );
  }
}
