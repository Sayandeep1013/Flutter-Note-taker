import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/noteModel.dart';
import '../../services/database_helper.dart';
import '../../provider/theme_provider.dart';
import '../views/note_view.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: const Text(
          'Delete Note',
          style: TextStyle(
            color: Colors.orange,
          ),
        ),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.orange,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.delete(note.id!);
      _refreshNotes();
    }
  }

  void _togglePin(NoteModel note) async {
    note.isPinned = !note.isPinned;
    await DatabaseHelper.instance.update(note);
    _refreshNotes();
  }

  List<NoteModel> get _filteredNotes {
    return _notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    ));

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : Colors.orange[50],
                  border: Border.all(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NOTES',
                      style: GoogleFonts.pacifico(
                        fontSize: 32,
                        color: isDarkMode ? Colors.orange : Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: isDarkMode ? Colors.orange : Colors.black,
                          ),
                          onPressed: () {
                            themeProvider.toggleTheme();
                          },
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: isDarkMode ? Colors.orange : Colors.black,
                          ),
                          onPressed: () {
                            showSearch(
                              context: context,
                              delegate: NoteSearchDelegate(
                                  _notes, _addOrEditNote, isDarkMode),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.orange[50],
                    border: Border.all(
                      color: Colors.orange,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.description,
                          style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Category: ${note.category}',
                          style: TextStyle(
                              color: isDarkMode
                                  ? Colors.orange
                                  : Colors.orange[800],
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    leading: IconButton(
                      icon: Icon(
                        note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        color: Colors.orange,
                      ),
                      onPressed: () => _togglePin(note),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.orange),
                      onPressed: () => _deleteNote(note),
                    ),
                    onTap: () => _addOrEditNote(note),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(null),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteSearchDelegate extends SearchDelegate<NoteModel?> {
  final List<NoteModel> notes;
  final Function(NoteModel?) onSelectNote;
  final bool isDarkMode;

  NoteSearchDelegate(this.notes, this.onSelectNote, this.isDarkMode);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.orange,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:
            TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
      ),
    );
  }

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
                note.description.toLowerCase().contains(query.toLowerCase()) ||
                note.category.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final note = suggestionList[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.description),
              Text(
                'Category: ${note.category}',
                style: TextStyle(
                  color: isDarkMode ? Colors.orange : Colors.orange[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          onTap: () {
            onSelectNote(note);
            close(context, note);
          },
        );
      },
    );
  }
}
