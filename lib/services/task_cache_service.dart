import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class TaskCacheService {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'ziko_cache.db'),
      version: 1,
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            date_time TEXT NOT NULL,
            priority TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> replaceAll(List<Task> tasks) async {
    final database = await _db;
    await database.transaction((transaction) async {
      await transaction.delete('tasks');
      for (final task in tasks) {
        await transaction.insert('tasks', task.toJson()..['id'] = task.id);
      }
    });
  }

  Future<List<Task>> getAll() async {
    final rows = await (await _db).query('tasks', orderBy: 'date_time ASC');
    return rows.map((row) => Task.fromJson(row)).toList();
  }
}
