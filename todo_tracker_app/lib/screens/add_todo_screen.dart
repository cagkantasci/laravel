import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class AddTodoScreen extends StatefulWidget {
  final Todo? todo; // Eğer null değilse edit mode

  const AddTodoScreen({super.key, this.todo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _selectedPriority = Priority.medium;
  String _selectedCategory = 'Backend';
  DateTime? _selectedDueDate;

  final List<String> _categories = [
    'Backend',
    'Frontend',
    'Mobile',
    'Database',
    'Testing',
    'UI/UX',
    'DevOps',
    'Dokümantasyon',
  ];

  bool get _isEditMode => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFields();
    }
  }

  void _populateFields() {
    final todo = widget.todo!;
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;
    _selectedPriority = todo.priority;
    _selectedCategory = todo.category;
    _selectedDueDate = todo.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Todo Düzenle' : 'Yeni Todo'),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: Text(
              _isEditMode ? 'Güncelle' : 'Kaydet',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık *',
                hintText: 'Todo başlığını girin',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Başlık gereklidir';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Todo açıklamasını girin',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Priority Selection
            const Text(
              'Öncelik *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Priority.values.map((priority) {
                final isSelected = _selectedPriority == priority;
                return FilterChip(
                  label: Text(priority.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPriority = priority;
                      });
                    }
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Color(priority.colorValue).withOpacity(0.2),
                  checkmarkColor: Color(priority.colorValue),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Due Date Picker
            Card(
              child: ListTile(
                title: const Text('Bitiş Tarihi'),
                subtitle: Text(
                  _selectedDueDate != null
                      ? DateFormat(
                          'dd MMMM yyyy, HH:mm',
                        ).format(_selectedDueDate!)
                      : 'Tarih seçilmedi',
                ),
                leading: const Icon(Icons.event),
                trailing: _selectedDueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _pickDateTime,
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveTodo,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isEditMode ? 'Güncelle' : 'Kaydet',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    // Pick Date
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    if (!mounted) return;

    // Pick Time
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? DateTime.now()),
    );

    if (time == null) return;

    setState(() {
      _selectedDueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _saveTodo() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final todo = Todo(
      id: _isEditMode ? widget.todo!.id : null,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      dueDate: _selectedDueDate,
      isCompleted: _isEditMode ? widget.todo!.isCompleted : false,
      createdAt: _isEditMode ? widget.todo!.createdAt : DateTime.now(),
    );

    final provider = context.read<TodoProvider>();

    if (_isEditMode) {
      provider.updateTodo(todo);
    } else {
      provider.addTodo(todo);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditMode ? 'Todo güncellendi' : 'Todo eklendi'),
      ),
    );
  }
}
