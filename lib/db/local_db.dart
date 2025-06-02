import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDb {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'user.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user(
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            province TEXT,
            birthPlace TEXT,
            birthDate TEXT,
            numberplate TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertUser({
    required String id,
    required String name,
    required String email,
    required String province,
    required String birthPlace,
    required String birthDate,
    required String numberplate,
  }) async {
    final db = await database;
    await db.insert(
      'user',
      {
        'id': id,
        'name': name,
        'email': email,
        'province': province,
        'birthPlace': birthPlace,
        'birthDate': birthDate,
        'numberplate': numberplate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final db = await database;
    final result = await db.query('user', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUser({
    required String id,
    required String name,
    required String email,
    required String province,
    required String birthPlace,
    required String birthDate,
  required String numberplate
  }) async {
    final db = await database;
    await db.update(
      'user',
      {
        'name': name,
        'email': email,
        'province': province,
        'birthPlace': birthPlace,
        'birthDate': birthDate,
        'numberplate':numberplate
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
