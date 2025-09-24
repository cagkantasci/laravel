import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<String> _categories = [];
  String _selectedCategory = 'Tümü';
  bool _showCompleted = false;
  bool _isLoading = false;

  // Getters
  List<Todo> get todos => _filteredTodos;
  List<String> get categories => ['Tümü', ..._categories];
  String get selectedCategory => _selectedCategory;
  bool get showCompleted => _showCompleted;
  bool get isLoading => _isLoading;

  List<Todo> get _filteredTodos {
    List<Todo> filtered = _todos;

    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      filtered = filtered
          .where((todo) => todo.category == _selectedCategory)
          .toList();
    }

    // Tamamlanma durumu filtresi
    if (!_showCompleted) {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    }

    // Öncelik ve tarihe göre sıralama
    filtered.sort((a, b) {
      // Tamamlanmamış önce
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Öncelik sırası (urgent -> high -> medium -> low)
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      // Son güncelleme tarihi
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return filtered;
  }

  // Completed todos count
  int get completedCount => _todos.where((todo) => todo.isCompleted).length;

  // Pending todos count
  int get pendingCount => _todos.where((todo) => !todo.isCompleted).length;

  // Overdue todos count
  int get overdueCount {
    final now = DateTime.now();
    return _todos
        .where(
          (todo) =>
              !todo.isCompleted &&
              todo.dueDate != null &&
              todo.dueDate!.isBefore(now),
        )
        .length;
  }

  // Initialize data
  Future<void> loadTodos() async {
    _setLoading(true);
    try {
      _todos = await DatabaseHelper.instance.queryAllTodos();
      _categories = await DatabaseHelper.instance.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new todo
  Future<void> addTodo(Todo todo) async {
    _setLoading(true);
    try {
      final id = await DatabaseHelper.instance.insert(todo);
      final newTodo = todo.copyWith(id: id);
      _todos.insert(0, newTodo);

      // Add category if it's new
      if (!_categories.contains(todo.category)) {
        _categories.add(todo.category);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update existing todo
  Future<void> updateTodo(Todo todo) async {
    _setLoading(true);
    try {
      await DatabaseHelper.instance.update(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle todo completion
  Future<void> toggleTodoCompleted(int id) async {
    try {
      await DatabaseHelper.instance.toggleCompleted(id);
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          isCompleted: !_todos[index].isCompleted,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling todo: $e');
    }
  }

  // Delete todo
  Future<void> deleteTodo(int id) async {
    _setLoading(true);
    try {
      await DatabaseHelper.instance.delete(id);
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set category filter
  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  // Toggle show completed
  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  // Search todos
  List<Todo> searchTodos(String query) {
    if (query.isEmpty) return _filteredTodos;

    final lowercaseQuery = query.toLowerCase();
    return _filteredTodos
        .where(
          (todo) =>
              todo.title.toLowerCase().contains(lowercaseQuery) ||
              todo.description.toLowerCase().contains(lowercaseQuery) ||
              todo.category.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Get todos by priority
  List<Todo> getTodosByPriority(Priority priority) {
    return _todos
        .where((todo) => todo.priority == priority && !todo.isCompleted)
        .toList();
  }

  // Get overdue todos
  List<Todo> getOverdueTodos() {
    final now = DateTime.now();
    return _todos
        .where(
          (todo) =>
              !todo.isCompleted &&
              todo.dueDate != null &&
              todo.dueDate!.isBefore(now),
        )
        .toList();
  }

  // Get today's todos
  List<Todo> getTodaysTodos() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    return _todos
        .where(
          (todo) =>
              todo.dueDate != null &&
              todo.dueDate!.isAfter(today) &&
              todo.dueDate!.isBefore(tomorrow),
        )
        .toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Laravel proje todo'larını yükle
  Future<void> loadLaravelProjectTodos() async {
    _setLoading(true);
    try {
      await DatabaseHelper.instance.resetDatabaseWithLaravelTodos();
      await loadTodos(); // Verileri yeniden yükle
    } catch (e) {
      debugPrint('Error loading Laravel todos: $e');
    } finally {
      _setLoading(false);
    }
  }
}
