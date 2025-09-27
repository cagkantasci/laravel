import 'package:flutter/material.dart';
import '../../../../core/services/mock_auth_service.dart';
import '../../../../core/services/permission_service.dart';

enum UserRole { admin, manager, operator }

class UserManagementUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
  final String? department;
  final String? phone;

  const UserManagementUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
    this.department,
    this.phone,
  });

  String get fullName => '$firstName $lastName';
  String get roleText {
    switch (role) {
      case UserRole.admin:
        return 'Yönetici';
      case UserRole.manager:
        return 'Müdür';
      case UserRole.operator:
        return 'Operatör';
    }
  }
}

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _selectedRoleFilter;
  String? _selectedDepartmentFilter;

  // Mock data
  final List<UserManagementUser> _users = [
    UserManagementUser(
      id: '1',
      firstName: 'Ahmet',
      lastName: 'Yılmaz',
      email: 'ahmet.yilmaz@smartop.com',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
      department: 'BT',
      phone: '+90 555 123 4567',
    ),
    UserManagementUser(
      id: '2',
      firstName: 'Fatma',
      lastName: 'Demir',
      email: 'fatma.demir@smartop.com',
      role: UserRole.manager,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 8)),
      isActive: true,
      department: 'Üretim',
      phone: '+90 555 987 6543',
    ),
    UserManagementUser(
      id: '3',
      firstName: 'Mehmet',
      lastName: 'Kaya',
      email: 'mehmet.kaya@smartop.com',
      role: UserRole.operator,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
      isActive: true,
      department: 'Üretim',
      phone: '+90 555 456 7890',
    ),
    UserManagementUser(
      id: '4',
      firstName: 'Ayşe',
      lastName: 'Öz',
      email: 'ayse.oz@smartop.com',
      role: UserRole.operator,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 12)),
      isActive: false,
      department: 'Kalite',
      phone: '+90 555 321 0987',
    ),
    UserManagementUser(
      id: '5',
      firstName: 'Can',
      lastName: 'Arslan',
      email: 'can.arslan@smartop.com',
      role: UserRole.manager,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 4)),
      isActive: true,
      department: 'Bakım',
      phone: '+90 555 654 3210',
    ),
  ];

  final List<String> _departments = ['BT', 'Üretim', 'Kalite', 'Bakım', 'İK'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<UserManagementUser> get _filteredUsers {
    return _users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user.fullName.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query) &&
            !(user.department?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Role filter
      if (_selectedRoleFilter != null && user.role != _selectedRoleFilter) {
        return false;
      }

      // Department filter
      if (_selectedDepartmentFilter != null &&
          user.department != _selectedDepartmentFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Check user management access
    final userRole = MockAuthService.getCurrentUserRole();
    final permissionService = PermissionService();

    if (!permissionService.canManageUsers(userRole ?? '')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kullanıcı Yönetimi')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Bu sayfaya erişim yetkiniz bulunmuyor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Sadece yöneticiler kullanıcı yönetimi yapabilir',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserDialog,
            tooltip: 'Yeni Kullanıcı Ekle',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh users
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kullanıcılar yenilendi')),
              );
            },
            tooltip: 'Yenile',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tüm Kullanıcılar', icon: Icon(Icons.people)),
            Tab(text: 'Aktif Kullanıcılar', icon: Icon(Icons.person)),
            Tab(text: 'Pasif Kullanıcılar', icon: Icon(Icons.person_off)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(_filteredUsers),
                _buildUserList(
                  _filteredUsers.where((u) => u.isActive).toList(),
                ),
                _buildUserList(
                  _filteredUsers.where((u) => !u.isActive).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
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
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<UserRole?>(
                  value: _selectedRoleFilter,
                  decoration: InputDecoration(
                    labelText: 'Rol Filtrele',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<UserRole?>(
                      value: null,
                      child: Text('Tüm Roller'),
                    ),
                    ...UserRole.values.map((role) {
                      String roleText;
                      switch (role) {
                        case UserRole.admin:
                          roleText = 'Yönetici';
                          break;
                        case UserRole.manager:
                          roleText = 'Müdür';
                          break;
                        case UserRole.operator:
                          roleText = 'Operatör';
                          break;
                      }
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(roleText),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedDepartmentFilter,
                  decoration: InputDecoration(
                    labelText: 'Departman Filtrele',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tüm Departmanlar'),
                    ),
                    ..._departments.map(
                      (dept) => DropdownMenuItem<String>(
                        value: dept,
                        child: Text(dept),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartmentFilter = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserManagementUser> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Kullanıcı bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arama kriterlerinizi değiştirin veya yeni kullanıcı ekleyin',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserManagementUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  child: Text(
                    user.firstName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: user.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: user.isActive
                                    ? Colors.green
                                    : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.isActive ? 'Aktif' : 'Pasif',
                              style: TextStyle(
                                color: user.isActive
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleUserAction(value, user),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: user.isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(user.isActive ? Icons.person_off : Icons.person),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'Pasifleştir' : 'Aktifleştir'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'resetPassword',
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset),
                          SizedBox(width: 8),
                          Text('Şifre Sıfırla'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.work, user.roleText),
                const SizedBox(width: 8),
                if (user.department != null)
                  _buildInfoChip(Icons.business, user.department!),
                const SizedBox(width: 8),
                if (user.phone != null)
                  _buildInfoChip(Icons.phone, user.phone!),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Son giriş: ${_formatDateTime(user.lastLoginAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Oluşturulma: ${_formatDate(user.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  void _handleUserAction(String action, UserManagementUser user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _showToggleUserStatusDialog(user);
        break;
      case 'resetPassword':
        _showResetPasswordDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditUserDialog(),
    );
  }

  void _showEditUserDialog(UserManagementUser user) {
    showDialog(
      context: context,
      builder: (context) => AddEditUserDialog(user: user),
    );
  }

  void _showToggleUserStatusDialog(UserManagementUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          user.isActive ? 'Kullanıcıyı Pasifleştir' : 'Kullanıcıyı Aktifleştir',
        ),
        content: Text(
          user.isActive
              ? '${user.fullName} kullanıcısını pasifleştirmek istediğinizden emin misiniz?'
              : '${user.fullName} kullanıcısını aktifleştirmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${user.fullName} ${user.isActive ? 'pasifleştirildi' : 'aktifleştirildi'}',
                  ),
                ),
              );
            },
            child: Text(user.isActive ? 'Pasifleştir' : 'Aktifleştir'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(UserManagementUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Sıfırla'),
        content: Text(
          '${user.fullName} kullanıcısının şifresini sıfırlamak istediğinizden emin misiniz? Kullanıcıya yeni şifre e-posta ile gönderilecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${user.fullName} kullanıcısının şifresi sıfırlandı',
                  ),
                ),
              );
            },
            child: const Text('Şifre Sıfırla'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(UserManagementUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Sil'),
        content: Text(
          '${user.fullName} kullanıcısını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.fullName} kullanıcısı silindi'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class AddEditUserDialog extends StatefulWidget {
  final UserManagementUser? user;

  const AddEditUserDialog({super.key, this.user});

  @override
  State<AddEditUserDialog> createState() => _AddEditUserDialogState();
}

class _AddEditUserDialogState extends State<AddEditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  UserRole _selectedRole = UserRole.operator;
  String? _selectedDepartment;
  bool _isActive = true;

  final List<String> _departments = ['BT', 'Üretim', 'Kalite', 'Bakım', 'İK'];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone ?? '';
      _selectedRole = widget.user!.role;
      _selectedDepartment = widget.user!.department;
      _isActive = widget.user!.isActive;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  List<UserRole> _getAvailableRoles() {
    final currentUserRole = MockAuthService.getCurrentUserRole();

    List<UserRole> availableRoles = [];

    // Admin can create any role
    if (currentUserRole == 'admin') {
      availableRoles = UserRole.values;
    }
    // Manager can only create operators
    else if (currentUserRole == 'manager') {
      availableRoles = [UserRole.operator];
    }

    return availableRoles;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return AlertDialog(
      title: Text(isEditing ? 'Kullanıcı Düzenle' : 'Yeni Kullanıcı Ekle'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Ad *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Ad gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Soyad *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Soyad gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'E-posta gereklidir';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value!)) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol *',
                        border: OutlineInputBorder(),
                      ),
                      items: _getAvailableRoles().map((role) {
                        String roleText = 'Bilinmiyor';
                        switch (role) {
                          case UserRole.admin:
                            roleText = 'Yönetici';
                            break;
                          case UserRole.manager:
                            roleText = 'Müdür';
                            break;
                          case UserRole.operator:
                            roleText = 'Operatör';
                            break;
                        }
                        return DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(roleText),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Departman',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Seçiniz'),
                        ),
                        ..._departments.map(
                          (dept) => DropdownMenuItem<String>(
                            value: dept,
                            child: Text(dept),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Aktif kullanıcı'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: _saveUser,
          child: Text(isEditing ? 'Güncelle' : 'Ekle'),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context);
      final action = widget.user != null ? 'güncellendi' : 'eklendi';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kullanıcı başarıyla $action')));
    }
  }
}
