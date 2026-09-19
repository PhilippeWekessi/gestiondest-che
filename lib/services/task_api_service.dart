import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_session.dart';

class TaskApiService {
  final AuthSession session;
  TaskApiService(this.session);

  static const String baseUrl = 'http://localhost:8000/api/tasks/';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (session.token != null) 'Authorization': 'Bearer ${session.token}',
  };

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse(baseUrl), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Task.fromJson(json)).toList();
    }
    throw Exception('Erreur lors du chargement des tâches');
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Erreur lors de la création de la tâche');
  }

  Future<Task> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl${task.id}/'),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Erreur lors de la modification de la tâche');
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl$id/'), headers: _headers);
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la tâche');
    }
  }
}