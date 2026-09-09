import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../modele/redacteur.dart';


class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._interne();
  factory DatabaseManager() => _instance;
  DatabaseManager._interne();

  Database? _database;


  Future<Database> get database async {
    _database ??= await _initialiserDatabase();
    return _database!;
  }

  Future<Database> _initialiserDatabase() async {
    final cheminBase = join(await getDatabasesPath(), 'redacteurs.db');
    return openDatabase(
      cheminBase,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE redacteurs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Récupération
  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;
    final lignes = await db.query('redacteurs', orderBy: 'nom ASC');
    return lignes.map((ligne) => Redacteur.fromMap(ligne)).toList();
  }

  /// Insertion
  Future<int> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    return db.insert(
      'redacteurs',
      redacteur.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mise à jour
  Future<int> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    return db.update(
      'redacteurs',
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  /// Suppression
  Future<int> deleteRedacteur(int id) async {
    final db = await database;
    return db.delete(
      'redacteurs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
