import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/financial_transaction.dart';
import '../../data/services/financial_service.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  final FinancialService _financialService = FinancialService();
  final AuthService _authService = AuthService();

  FinancialSummary? _summary;
  List<FinancialTransaction> _transactions = [];
  bool _isLoading = false;
  String? _selectedType;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final user = _authService.currentUser;
    if (user == null || (!user.isAdmin && !user.isManager)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu sayfaya erişim yetkiniz yok')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      final summary = await _financialService.getSummary(
        startDate: DateFormat('yyyy-MM-dd').format(startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
      );

      final transactions = await _financialService.getTransactions(
        type: _selectedType,
        category: _selectedCategory,
        perPage: 20,
      );

      setState(() {
        _summary = summary;
        _transactions = transactions;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount, [String currency = 'TRY']) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: currency == 'TRY' ? '₺' : currency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  Color _getTypeColor(String type) {
    return type == 'income'
        ? const Color(AppColors.successGreen)
        : const Color(AppColors.errorRed);
  }

  IconData _getTypeIcon(String type) {
    return type == 'income' ? Icons.trending_up : Icons.trending_down;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finans Yönetimi'),
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading && _summary == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (_summary != null) _buildSummaryCards(),
                    _buildTransactionsList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(),
        backgroundColor: const Color(AppColors.primaryBlue),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Toplam Gelir',
                  _formatCurrency(_summary!.totalIncome),
                  const Color(AppColors.successGreen),
                  Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: _buildSummaryCard(
                  'Toplam Gider',
                  _formatCurrency(_summary!.totalExpense),
                  const Color(AppColors.errorRed),
                  Icons.arrow_downward,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildSummaryCard(
            'Net Tutar',
            _formatCurrency(_summary!.netAmount),
            _summary!.netAmount >= 0
                ? const Color(AppColors.successGreen)
                : const Color(AppColors.errorRed),
            _summary!.netAmount >= 0 ? Icons.check_circle : Icons.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: AppSizes.iconMedium),
                const SizedBox(width: AppSizes.paddingSmall),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppSizes.textSmall,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: AppSizes.textXLarge,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Center(
          child: Text('Henüz işlem kaydı bulunmuyor'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(FinancialTransaction transaction) {
    final typeColor = _getTypeColor(transaction.type);
    final typeIcon = _getTypeIcon(transaction.type);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.1),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.category),
            Text(
              DateFormat('dd MMM yyyy', 'tr_TR').format(transaction.transactionDate),
              style: const TextStyle(fontSize: AppSizes.textSmall),
            ),
          ],
        ),
        trailing: Text(
          _formatCurrency(transaction.amount, transaction.currency),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.textLarge,
            color: typeColor,
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Tür'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tümü')),
                DropdownMenuItem(value: 'income', child: Text('Gelir')),
                DropdownMenuItem(value: 'expense', child: Text('Gider')),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedCategory = null;
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    // TODO: Implement add transaction dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni işlem ekleme özelliği yakında eklenecek')),
    );
  }

  void _showTransactionDetails(FinancialTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tür', transaction.type == 'income' ? 'Gelir' : 'Gider'),
            _buildDetailRow('Kategori', transaction.category),
            _buildDetailRow('Tutar', _formatCurrency(transaction.amount, transaction.currency)),
            _buildDetailRow('Tarih', DateFormat('dd MMMM yyyy', 'tr_TR').format(transaction.transactionDate)),
            _buildDetailRow('Durum', _getStatusText(transaction.status)),
            if (transaction.description != null)
              _buildDetailRow('Açıklama', transaction.description!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Tamamlandı';
      case 'pending':
        return 'Beklemede';
      case 'cancelled':
        return 'İptal';
      default:
        return status;
    }
  }
}
