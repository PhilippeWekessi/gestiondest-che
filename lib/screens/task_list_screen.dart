import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../services/task_api_service.dart';
import 'task_detail_screen.dart';
import 'add_edit_task_screen.dart';
import '../services/auth_session.dart';
import '../services/auth_api_service.dart';
import 'profile_screen.dart';

class TaskListScreen extends StatefulWidget {
  final AuthSession session;
  final VoidCallback onLogout;

  const TaskListScreen({
    super.key,
    required this.session,
    required this.onLogout,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskApiService _apiService;

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  TaskPriority? _activeFilter; // null = "Toutes"
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _apiService = TaskApiService(widget.session);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tasks = await _apiService.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            "Impossible de charger les tâches. Vérifie que le serveur API est disponible.";
        _isLoading = false;
      });
    }
  }

  List<Task> get _filteredTasks {
    return _tasks.where((task) {
      final matchesPriority =
          _activeFilter == null || task.priority == _activeFilter;
      final matchesSearch = task.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesPriority && matchesSearch;
    }).toList();
  }

  Future<void> _openAddTask() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
    if (newTask != null) {
      try {
        final createdTask = await _apiService.createTask(newTask);
        setState(() => _tasks.add(createdTask));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erreur lors de la création de la tâche."),
            ),
          );
        }
      }
    }
  }

  Future<void> _openTaskDetail(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );

    if (result == 'deleted') {
      try {
        await _apiService.deleteTask(task.id);
        setState(() => _tasks.removeWhere((t) => t.id == task.id));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erreur lors de la suppression de la tâche."),
            ),
          );
        }
      }
    } else if (result is Task) {
      try {
        final updatedTask = await _apiService.updateTask(result);
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
          if (index != -1) _tasks[index] = updatedTask;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erreur lors de la modification de la tâche."),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mes tâches',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.ink),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(session: widget.session),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.ink),
            onPressed: () async {
              await AuthApiService(widget.session).logout();
              if (mounted) widget.onLogout();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.ink),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: _openAddTask,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadTasks,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une tâche par titre',
              prefixIcon: const Icon(Icons.search, color: AppColors.inkSoft),
              filled: true,
              fillColor: AppColors.paper,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('Toutes', null),
              _buildFilterChip('Élevée', TaskPriority.high),
              _buildFilterChip('Moyenne', TaskPriority.medium),
              _buildFilterChip('Basse', TaskPriority.low),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredTasks.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune tâche trouvée',
                    style: TextStyle(color: AppColors.inkSoft),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: _filteredTasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return _TaskCard(
                        task: task,
                        onTap: () => _openTaskDetail(task),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, TaskPriority? priority) {
    final isActive = _activeFilter == priority;
    final color = priority?.color ?? AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => setState(() => _activeFilter = priority),
        selectedColor: priority == null
            ? AppColors.ink
            : color.withValues(alpha: 0.12),
        backgroundColor: AppColors.paper,
        labelStyle: TextStyle(
          color: isActive
              ? (priority == null ? Colors.white : color)
              : AppColors.inkSoft,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        side: BorderSide(color: isActive ? color : AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: task.priority.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: task.priority.backgroundColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          task.priority.label,
                          style: TextStyle(
                            color: task.priority.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${task.dateTime.day}/${task.dateTime.month}/${task.dateTime.year} · '
                    '${task.dateTime.hour.toString().padLeft(2, '0')}:${task.dateTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkSoft,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
