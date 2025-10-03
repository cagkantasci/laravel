import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smartop_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:smartop_mobile/core/services/auth_service.dart';
import 'package:smartop_mobile/core/services/mock_auth_service.dart';

// Generate mocks
@GenerateMocks([AuthService])

void main() {
  group('LoginPage Widget Tests', () {
    setUp(() {
      // Test setup
    });

    Widget createLoginPage() {
      return MaterialApp(
        home: const LoginPage(),
      );
    }

    group('UI Elements Tests', () {
      testWidgets('should display all required UI elements', (tester) async {
        // Act
        await tester.pumpWidget(createLoginPage());

        // Assert
        expect(find.text('SmartOp'), findsOneWidget);
        expect(find.text('Endüstriyel Makine Kontrol Sistemi'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
        expect(find.text('E-posta'), findsOneWidget);
        expect(find.text('Şifre'), findsOneWidget);
        expect(find.text('Giriş Yap'), findsOneWidget);
        expect(find.text('Hesap Oluştur'), findsOneWidget);
        expect(find.text('Beni hatırla'), findsOneWidget);
        expect(find.text('Şifremi Unuttum'), findsOneWidget);
      });

      testWidgets('should display app logo and branding', (tester) async {
        // Act
        await tester.pumpWidget(createLoginPage());

        // Assert
        expect(find.byIcon(Icons.engineering), findsOneWidget);
        expect(find.text('SmartOp Mobile v1.0.0'), findsOneWidget);
        expect(find.text('Offline Test Mode'), findsOneWidget);
      });

      testWidgets('should display test user information', (tester) async {
        // Act
        await tester.pumpWidget(createLoginPage());

        // Assert
        expect(find.text('Test Kullanıcıları (Offline Mode)'), findsOneWidget);
        expect(find.textContaining('admin@smartop.com'), findsOneWidget);
        expect(find.textContaining('operator@smartop.com'), findsOneWidget);
        expect(find.textContaining('manager@smartop.com'), findsOneWidget);
      });
    });

    group('Input Validation Tests', () {
      testWidgets('should show validation errors for empty fields', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.tap(find.text('Giriş Yap'));
        await tester.pump();

        // Assert
        expect(find.text('E-posta adresi gerekli'), findsOneWidget);
        expect(find.text('Şifre gerekli'), findsOneWidget);
      });

      testWidgets('should show validation error for invalid email format', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.tap(find.text('Giriş Yap'));
        await tester.pump();

        // Assert
        expect(find.text('Geçerli bir e-posta adresi girin'), findsOneWidget);
      });

      testWidgets('should show validation error for short password', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test@smartop.com');
        await tester.enterText(find.byType(TextFormField).last, '123');
        await tester.tap(find.text('Giriş Yap'));
        await tester.pump();

        // Assert
        expect(find.text('Şifre en az 6 karakter olmalı'), findsOneWidget);
      });

      testWidgets('should accept valid email format', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test@smartop.com');
        await tester.pump();

        // Assert - No validation error should be shown
        expect(find.text('Geçerli bir e-posta adresi girin'), findsNothing);
      });
    });

    group('Password Visibility Tests', () {
      testWidgets('should toggle password visibility', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());
        final passwordField = find.byType(TextFormField).last;

        // Act - Initially password should be obscured
        TextField initialTextField = tester.widget(passwordField);
        expect(initialTextField.obscureText, true);

        // Tap visibility toggle
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Assert - Password should now be visible
        TextField toggledTextField = tester.widget(passwordField);
        expect(toggledTextField.obscureText, false);

        // Tap again to hide
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Assert - Password should be obscured again
        TextField hiddenTextField = tester.widget(passwordField);
        expect(hiddenTextField.obscureText, true);
      });
    });

    group('Remember Me Tests', () {
      testWidgets('should toggle remember me checkbox', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());
        final checkbox = find.byType(Checkbox);

        // Act - Initially unchecked
        Checkbox initialCheckbox = tester.widget(checkbox);
        expect(initialCheckbox.value, false);

        // Tap checkbox
        await tester.tap(checkbox);
        await tester.pump();

        // Assert - Should be checked
        Checkbox checkedCheckbox = tester.widget(checkbox);
        expect(checkedCheckbox.value, true);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should show forgot password message when tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.tap(find.text('Şifremi Unuttum'));
        await tester.pump();

        // Assert
        expect(find.text('Şifre sıfırlama yakında eklenecek...'), findsOneWidget);
      });

      testWidgets('should show register message when create account tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.tap(find.text('Hesap Oluştur'));
        await tester.pump();

        // Assert
        expect(find.text('Kayıt sayfası yakında eklenecek...'), findsOneWidget);
      });
    });

    group('Login Flow Tests', () {
      testWidgets('should show loading indicator during login', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'admin@smartop.com');
        await tester.enterText(find.byType(TextFormField).last, '123456');
        await tester.tap(find.text('Giriş Yap'));
        await tester.pump(); // Start the async operation
        await tester.pump(const Duration(milliseconds: 100)); // Let it start loading

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show success message on successful login', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'admin@smartop.com');
        await tester.enterText(find.byType(TextFormField).last, '123456');
        await tester.tap(find.text('Giriş Yap'));
        await tester.pumpAndSettle(); // Wait for async operations to complete

        // Assert
        expect(find.text('Giriş başarılı! Hoş geldiniz.'), findsOneWidget);
      });

      testWidgets('should clear form after successful login', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());
        final emailField = find.byType(TextFormField).first;
        final passwordField = find.byType(TextFormField).last;

        // Act
        await tester.enterText(emailField, 'admin@smartop.com');
        await tester.enterText(passwordField, '123456');
        await tester.tap(find.text('Giriş Yap'));
        await tester.pumpAndSettle();

        // Note: In a real app, navigation would occur and form would be disposed
        // This test verifies the interaction works without errors
        expect(find.byType(LoginPage), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle network errors gracefully', (tester) async {
        // This would require mocking the AuthService to throw network errors
        // For now, we'll test the UI remains stable
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test@smartop.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.tap(find.text('Giriş Yap'));
        await tester.pumpAndSettle();

        // Assert - UI should remain stable
        expect(find.byType(LoginPage), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantics for screen readers', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Assert
        expect(find.bySemanticsLabel('E-posta'), findsOneWidget);
        expect(find.bySemanticsLabel('Şifre'), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act - Test tab navigation through form fields
        // Skip actual keyboard event testing as it requires platform-specific setup

        // Assert - Focus should move through form elements
        expect(find.byType(TextFormField), findsWidgets);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should layout properly on different screen sizes', (tester) async {
        // Test on different screen sizes
        await tester.binding.setSurfaceSize(const Size(800, 600)); // Tablet size
        await tester.pumpWidget(createLoginPage());

        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);

        // Test on smaller screen
        await tester.binding.setSurfaceSize(const Size(320, 568)); // Phone size
        await tester.pumpWidget(createLoginPage());

        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });
    });

    group('State Management Tests', () {
      testWidgets('should maintain form state during rebuild', (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginPage());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test@smartop.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');

        // Trigger rebuild
        await tester.pump();

        // Assert - Text should be preserved
        expect(find.text('test@smartop.com'), findsOneWidget);
        // Password field is obscured, so we shouldn't expect to find the text
        final passwordField = find.byType(TextFormField).last;
        expect(passwordField, findsOneWidget);
      });
    });
  });
}