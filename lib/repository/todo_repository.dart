import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

// Creazione del Database
class TodoRepository {
  late Database database;

  Future<void> initialize() async {
    final databasePath = await getDatabasesPath();
    final dbPath = path.join(databasePath, "todos.db");

    database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute("""
        CREATE TABLE todos(
          id INTEGER PRIMARY KEY,
          text TEXT
        );
      """);
      },
    );
  }

  // Funzione che Seleziona tutti i Dati Salvati per Mostrarli all'Utente
  Future<List<String>> all() async {
    final records = await database.query("todos");
    return records.map((record) => record["text"] as String).toList();
  }

  // Funzione che Inserisce i Dati nel Database
  Future<void> create(String todo) async {
    await database.insert("todos", {
      "text": todo,
    });
  }

  // Funzione che Elimina i Dati dal Database
  Future<void> delete(String todo) async {
    database.delete(
      "todos",
      where: "text = ?",
      whereArgs: [todo],
    );
  }
}
