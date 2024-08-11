import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/noteModel.dart';
import '../../services/database_helper.dart';
import '../../provider/theme_provider.dart';

class NoteView extends StatefulWidget {
  final NoteModel? note;

  const NoteView({Key? key, this.note}) : super(key: key);

  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _category;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
    _category = widget.note?.category ?? 'Uncategorized';
    _isPinned = widget.note?.isPinned ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove default back arrow
          flexibleSpace: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.orange),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          widget.note == null ? 'ADD NOTE' : 'EDIT NOTE',
                          style: GoogleFonts.pacifico(
                            fontSize: 24,
                            color: isDarkMode ? Colors.orange : Colors.black,
                          ),
                        ),
                      ],
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
                            _isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            color: isDarkMode ? Colors.orange : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPinned = !_isPinned;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(
                  color: Colors.orange,
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.orange[50],
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(
                  color: Colors.orange,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.orange[50],
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.orange[50],
                border: Border.all(
                  color: Colors.orange,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(
                    color: Colors.orange,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                dropdownColor:
                    isDarkMode ? Colors.black : Colors.orange[50],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                items: ['Uncategorized', 'Work', 'Personal', 'Ideas']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.black : Colors.orange[50],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              child: Text(
                'Save Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.orangeAccent : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final note = NoteModel(
        id: widget.note?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        isPinned: _isPinned,
      );

      final dbHelper = DatabaseHelper.instance;
      if (widget.note == null) {
        await dbHelper.insert(note);
      } else {
        await dbHelper.update(note);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
