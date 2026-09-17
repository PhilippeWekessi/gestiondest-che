import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'auth_session.dart';
import 'task_cache_service.dart';

class TaskApiService {
  static const baseUrl = 'http://localhost:8000/api/tasks/';

  final AuthSession session;
  final TaskCacheService cache;

  TaskApiService(this.session, {TaskCacheService? cache})
    : cache = cache ?? TaskCacheService();

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: _headers);
      if (response.statusCode != 200) throw Exception('API indisponible');
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      final tasks = data.map((item) => Task.fromJson(item)).toList();
      await cache.replaceAll(tasks);
      return tasks;
    } catch (_) {
      final cachedTasks = await cache.getAll();
      if (cachedTasks.isNotEmpty) return cachedTasks;
      final preferences = await SharedPreferences.getInstance();
      if (preferences.getBool('demo_tasks_seeded') != true) {
        await cache.replaceAll(_demoTasks);
        await preferences.setBool('demo_tasks_seeded', true);
        return _demoTasks;
      }
      return [];
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode(task.toJson()),
      );
      if (response.statusCode != 201) throw Exception('Création impossible');
      final created = Task.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
      await _upsertCache(created);
      return created;
    } catch (_) {
      await _upsertCache(task);
      return task;
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${task.id}/'),
        headers: _headers,
        body: jsonEncode(task.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Modification impossible');
      }
      final updated = Task.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
      await _upsertCache(updated);
      return updated;
    } catch (_) {
      await _upsertCache(task);
      return task;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$id/'),
        headers: _headers,
      );
      if (response.statusCode != 204) throw Exception('Suppression impossible');
    } catch (_) {
      // La suppression locale permet de poursuivre le travail hors connexion.
    }
    final tasks = await cache.getAll()
      ..removeWhere((task) => task.id == id);
    await cache.replaceAll(tasks);
  }

  Future<void> _upsertCache(Task task) async {
    final tasks = await cache.getAll();
    final index = tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      tasks.add(task);
    } else {
      tasks[index] = task;
    }
    await cache.replaceAll(tasks);
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${session.token}',
  };

  List<Task> get _demoTasks => [
    Task(
      id: 'demo-1',
      title: 'Préparer la soutenance',
      content: 'Finaliser les slides et répéter la présentation.',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
    ),
    Task(
      id: 'demo-2',
      title: 'Répondre aux emails',
      content: 'Traiter les messages importants de la journée.',
      dateTime: DateTime.now().add(const Duration(hours: 4)),
      priority: TaskPriority.medium,
    ),
  ];
}
