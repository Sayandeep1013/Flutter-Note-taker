import 'package:flutter/material.dart';
import '../../models/noteModel.dart';
import '../../services/database_helper.dart';
import '../views/note_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NoteModel> _notes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final notes = await DatabaseHelper.instance.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  void _addOrEditNote(NoteModel? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteView(note: note)),
    );

    if (result == true) {
      _refreshNotes();
    }
  }

  void _deleteNote(NoteModel note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.delete(note.id!);
      _refreshNotes();
    }
  }

  List<NoteModel> get _filteredNotes {
    return _notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(_notes, _addOrEditNote),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) {
          final note = _filteredNotes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.description),
            leading: Icon(
              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: note.isPinned ? Colors.red : null,
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteNote(note),
            ),
            onTap: () => _addOrEditNote(note),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(null),
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteSearchDelegate extends SearchDelegate<NoteModel?> {
  final List<NoteModel> notes;
  final Function(NoteModel?) onSelectNote;

  NoteSearchDelegate(this.notes, this.onSelectNote);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? notes
        : notes.where((note) {
            return note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.description.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final note = suggestionList[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.description),
          onTap: () {
            onSelectNote(note);
            close(context, note);
          },
        );
      },
    );
  }
}
