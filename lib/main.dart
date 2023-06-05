import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(NotesApp());
}

class Note {
  String title;
  String content;

  Note({
    required this.title,
    required this.content,
  });
}

class NotesApp extends StatefulWidget {
  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  final List<Note> _notes = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: NotesHomePage(_notes),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  final List<Note> notes;

  NotesHomePage(this.notes);

  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedIndex = -1;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void addNote() {
    final title = _titleController.text;
    final content = _contentController.text;

    setState(() {
      widget.notes.add(Note(
        title: title,
        content: content,
      ));
    });

    _titleController.clear();
    _contentController.clear();
  }

  void updateNote() {
    final title = _titleController.text;
    final content = _contentController.text;

    setState(() {
      widget.notes[_selectedIndex].title = title;
      widget.notes[_selectedIndex].content = content;
    });

    _titleController.clear();
    _contentController.clear();
    _selectedIndex = -1;
  }

  void copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note copied to clipboard'),
      ),
    );
  }

  void deleteNote() {
    setState(() {
      widget.notes.removeAt(_selectedIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note Deleted'),
      ),
    );
    _selectedIndex = -1;
  }

  void editNote() {
    final selectedNote = widget.notes[_selectedIndex];
    _titleController.text = selectedNote.title;
    _contentController.text = selectedNote.content;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note edited'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    focusColor: Colors.green,
                    prefixIcon: Icon(Icons.title_sharp),
                    labelText: 'Title',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.content_paste_sharp),
                    labelText: 'Content',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_selectedIndex == -1) {
                  addNote();
                } else {
                  updateNote();
                }
              }
            },
            child: Text(_selectedIndex == -1 ? 'Save Note' : 'Update Note'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.notes.length,
              itemBuilder: (context, index) {
                final title = widget.notes[index].title;
                final content = widget.notes[index].content;
                return ListTile(
                  title: Text(title),
                  subtitle: Text(content),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () => copyToClipboard(content),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          deleteNote();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          editNote();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}