import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/statistics_card.dart';
import 'add_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load todos when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laravel Proje Takip'),
        actions: [
          // Laravel Todo'larını Yükle Butonu
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Laravel Todo\'larını Yükle',
                onPressed: () => _showLoadLaravelTodosDialog(context, provider),
              );
            },
          ),
          // Tamamlananları Göster/Gizle
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.showCompleted
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                tooltip: provider.showCompleted
                    ? 'Tamamlananları Gizle'
                    : 'Tamamlananları Göster',
                onPressed: () {
                  provider.toggleShowCompleted();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Statistics Cards
              _buildStatisticsSection(provider),

              // Search Bar
              _buildSearchBar(provider),

              // Category Filter
              _buildCategoryFilter(provider),

              // Todo List
              Expanded(child: _buildTodoList(provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTodoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsSection(TodoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatisticsCard(
              title: 'Bekleyen',
              count: provider.pendingCount,
              color: Colors.orange,
              icon: Icons.pending_actions,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatisticsCard(
              title: 'Tamamlanan',
              count: provider.completedCount,
              color: Colors.green,
              icon: Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatisticsCard(
              title: 'Geciken',
              count: provider.overdueCount,
              color: Colors.red,
              icon: Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TodoProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Todo ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter(TodoProvider provider) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final isSelected = provider.selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                provider.setSelectedCategory(category);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodoList(TodoProvider provider) {
    List<Todo> todosToShow = _searchQuery.isEmpty
        ? provider.todos
        : provider.searchTodos(_searchQuery);

    if (todosToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.task_alt,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Arama sonucu bulunamadı'
                  : 'Henüz todo eklenmemiş',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Farklı anahtar kelimeler deneyin'
                  : 'İlk todo\'nunu eklemek için + butonuna dokun',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: todosToShow.length,
      itemBuilder: (context, index) {
        final todo = todosToShow[index];
        return TodoCard(
          todo: todo,
          onToggle: () => provider.toggleTodoCompleted(todo.id!),
          onEdit: () => _editTodo(todo),
          onDelete: () => _deleteTodo(provider, todo),
        );
      },
    );
  }

  void _editTodo(Todo todo) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddTodoScreen(todo: todo)));
  }

  void _deleteTodo(TodoProvider provider, Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Todo Sil'),
        content: Text(
          '"${todo.title}" todo\'sunu silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTodo(todo.id!);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Todo silindi')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showLoadLaravelTodosDialog(
    BuildContext context,
    TodoProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laravel Proje Todo\'larını Yükle'),
        content: const Text(
          'Bu işlem mevcut tüm todo\'ları silip Laravel İş Makinesi Kontrol Sistemi '
          'projesinin 20 todo\'sunu yükleyecek. Devam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Loading dialog göster
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Laravel todo\'ları yükleniyor...'),
                    ],
                  ),
                ),
              );

              try {
                await provider.loadLaravelProjectTodos();
                Navigator.of(context).pop(); // Loading dialog'u kapat

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Laravel proje todo\'ları başarıyla yüklendi! (20 todo)',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop(); // Loading dialog'u kapat
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yükle'),
          ),
        ],
      ),
    );
  }
}
