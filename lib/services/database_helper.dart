import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/noteModel.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      category TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      isPinned INTEGER NOT NULL
    )
  ''');
  }

  Future<int> insert(NoteModel note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<NoteModel>> getNotes() async {
    final db = await instance.database;
    final result =
        await db.query('notes', orderBy: 'isPinned DESC, createdAt DESC');
    return result.map((json) => NoteModel.fromMap(json)).toList();
  }

  Future<int> update(NoteModel note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
