class FinancialTransaction {
  final int id;
  final int companyId;
  final int? userId;
  final String type; // 'income' or 'expense'
  final String category;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final DateTime transactionDate;
  final String status; // 'pending', 'completed', 'cancelled'
  final String? referenceNumber;
  final String? paymentMethod;
  final String? attachmentUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialTransaction({
    required this.id,
    required this.companyId,
    this.userId,
    required this.type,
    required this.category,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
    required this.transactionDate,
    required this.status,
    this.referenceNumber,
    this.paymentMethod,
    this.attachmentUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      userId: json['user_id'],
      type: json['type'] ?? 'expense',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TRY',
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      referenceNumber: json['reference_number'],
      paymentMethod: json['payment_method'],
      attachmentUrl: json['attachment_url'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'user_id': userId,
      'type': type,
      'category': category,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'transaction_date': transactionDate.toIso8601String(),
      'status': status,
      'reference_number': referenceNumber,
      'payment_method': paymentMethod,
      'attachment_url': attachmentUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final Map<String, double> incomeByCategory;
  final Map<String, double> expenseByCategory;
  final DateTime startDate;
  final DateTime endDate;

  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.incomeByCategory,
    required this.expenseByCategory,
    required this.startDate,
    required this.endDate,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      netAmount: (json['net_amount'] ?? 0).toDouble(),
      incomeByCategory: Map<String, double>.from(
        (json['income_by_category'] ?? {}).map(
          (key, value) => MapEntry(key.toString(), (value ?? 0).toDouble()),
        ),
      ),
      expenseByCategory: Map<String, double>.from(
        (json['expense_by_category'] ?? {}).map(
          (key, value) => MapEntry(key.toString(), (value ?? 0).toDouble()),
        ),
      ),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
    );
  }
}
