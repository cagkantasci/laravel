import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../models/financial_transaction.dart';

class FinancialService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = _authService.currentToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all financial transactions with filters
  Future<List<FinancialTransaction>> getTransactions({
    String? type,
    String? category,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (type != null) 'type': type,
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (search != null) 'search': search,
      };

      final uri = Uri.parse('${AppConstants.apiBaseUrl}/financial-transactions')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transactions = (data['data']['data'] as List)
            .map((json) => FinancialTransaction.fromJson(json))
            .toList();
        return transactions;
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading transactions: $e');
    }
  }

  // Get financial summary
  Future<FinancialSummary> getSummary({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'start_date': startDate,
        'end_date': endDate,
      };

      final uri = Uri.parse('${AppConstants.apiBaseUrl}/financial-summary')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FinancialSummary.fromJson(data['data']);
      } else {
        throw Exception('Failed to load summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading summary: $e');
    }
  }

  // Create new transaction
  Future<FinancialTransaction> createTransaction({
    required String type,
    required String category,
    required String title,
    String? description,
    required double amount,
    String currency = 'TRY',
    required DateTime transactionDate,
    String status = 'completed',
    String? referenceNumber,
    String? paymentMethod,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'type': type,
        'category': category,
        'title': title,
        'description': description,
        'amount': amount,
        'currency': currency,
        'transaction_date': transactionDate.toIso8601String().split('T')[0],
        'status': status,
        'reference_number': referenceNumber,
        'payment_method': paymentMethod,
      });

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/financial-transactions'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FinancialTransaction.fromJson(data['data']);
      } else {
        throw Exception('Failed to create transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  // Update transaction
  Future<FinancialTransaction> updateTransaction({
    required int id,
    String? type,
    String? category,
    String? title,
    String? description,
    double? amount,
    String? currency,
    DateTime? transactionDate,
    String? status,
    String? referenceNumber,
    String? paymentMethod,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        if (type != null) 'type': type,
        if (category != null) 'category': category,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency,
        if (transactionDate != null)
          'transaction_date': transactionDate.toIso8601String().split('T')[0],
        if (status != null) 'status': status,
        if (referenceNumber != null) 'reference_number': referenceNumber,
        if (paymentMethod != null) 'payment_method': paymentMethod,
      });

      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/financial-transactions/$id'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FinancialTransaction.fromJson(data['data']);
      } else {
        throw Exception('Failed to update transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(int id) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/financial-transactions/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  // Get common categories
  List<String> getIncomeCategories() {
    return [
      'Satış',
      'Hizmet',
      'Abonelik',
      'Danışmanlık',
      'Diğer Gelir',
    ];
  }

  List<String> getExpenseCategories() {
    return [
      'Maaş',
      'Kira',
      'Elektrik',
      'Su',
      'İnternet',
      'Bakım-Onarım',
      'Malzeme',
      'Ulaşım',
      'Pazarlama',
      'Diğer Gider',
    ];
  }

  List<String> getPaymentMethods() {
    return [
      'Nakit',
      'Kredi Kartı',
      'Banka Transferi',
      'Çek',
      'Diğer',
    ];
  }
}
