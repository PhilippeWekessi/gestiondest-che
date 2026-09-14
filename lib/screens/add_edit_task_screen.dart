import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';

/// Écran unique pour l'ajout ET la modification d'une tâche.
/// Si [existingTask] est fourni, le formulaire est pré-rempli et le titre
/// de la page passe à "Modifier la tâche" (comme demandé dans le cahier des charges).
class AddEditTaskScreen extends StatefulWidget {
  final Task? existingTask;

  const AddEditTaskScreen({super.key, this.existingTask});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late TaskPriority _priority;
  late DateTime _date;
  late TimeOfDay _time;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _contentController = TextEditingController(text: task?.content ?? '');
    _priority = task?.priority ?? TaskPriority.high;
    _date = task?.dateTime ?? DateTime.now();
    _time = task != null
        ? TimeOfDay(hour: task.dateTime.hour, minute: task.dateTime.minute)
        : TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le titre est obligatoire.')));
      return;
    }

    final dateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    final task = Task(
      id: widget.existingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      dateTime: dateTime,
      priority: _priority,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text(
          _isEditing ? 'Modifier la tâche' : 'Nouvelle tâche',
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            _buildLabel('Titre'),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('ex. Préparer la soutenance'),
            ),
            const SizedBox(height: 16),
            _buildLabel('Contenu'),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: _inputDecoration('Détaille ce qu\'il y a à faire...'),
            ),
            const SizedBox(height: 16),
            _buildLabel('Priorité'),
            Row(
              children: TaskPriority.values.map((priority) {
                final isSelected = _priority == priority;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = priority),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? priority.backgroundColor
                              : AppColors.paper,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? priority.color : AppColors.line,
                          ),
                        ),
                        child: Text(
                          priority.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: isSelected ? priority.color : AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Date'),
                      _buildPickerField(
                        text:
                            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                        icon: Icons.calendar_today,
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Heure'),
                      _buildPickerField(
                        text: _time.format(context),
                        icon: Icons.access_time,
                        onTap: _pickTime,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enregistrer la tâche',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSoft,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.paper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
    );
  }

  // Champ non-éditable qui ouvre un sélecteur (date ou heure) au tap,
  // pour que l'utilisateur choisisse plutôt que d'écrire la date à la main.
  Widget _buildPickerField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.inkSoft),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 14.5, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}