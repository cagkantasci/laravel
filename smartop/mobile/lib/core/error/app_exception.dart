class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ApiException($statusCode): $message\nErrors: $errors';
    }
    return 'ApiException($statusCode): $message';
  }

  // Check if it's a network error
  bool get isNetworkError => statusCode == 0;

  // Check if it's a client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  // Check if it's a server error (5xx)
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  // Check if it's unauthorized
  bool get isUnauthorized => statusCode == 401;

  // Check if it's forbidden
  bool get isForbidden => statusCode == 403;

  // Check if it's not found
  bool get isNotFound => statusCode == 404;

  // Check if it's validation error
  bool get isValidationError => statusCode == 422;

  // Get user-friendly error message
  String get userMessage {
    switch (statusCode) {
      case 0:
        return 'İnternet bağlantısı bulunamadı';
      case 401:
        return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın';
      case 403:
        return 'Bu işlem için yetkiniz bulunmuyor';
      case 404:
        return 'İstenen kaynak bulunamadı';
      case 422:
        return 'Girilen bilgiler geçersiz';
      case >= 500:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin';
      default:
        return message;
    }
  }

  // Get validation errors as a formatted string
  String get validationErrorsText {
    if (errors == null || errors!.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    errors!.forEach((field, messages) {
      if (messages is List) {
        for (final message in messages) {
          buffer.writeln('• $message');
        }
      } else {
        buffer.writeln('• $messages');
      }
    });

    return buffer.toString().trim();
  }
}
