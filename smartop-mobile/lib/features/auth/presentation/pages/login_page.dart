import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Giriş başarılı! Hoş geldiniz.'),
              backgroundColor: const Color(AppColors.successGreen),
            ),
          );

          // Navigate to Dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Giriş başarısız!'),
              backgroundColor: const Color(AppColors.errorRed),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: const Color(AppColors.errorRed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.grey50),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.paddingXLarge),

              // Logo ve Başlık
              _buildHeader(),

              const SizedBox(height: AppSizes.paddingXLarge * 2),

              // Login Form
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildEmailField(),
                        const SizedBox(height: AppSizes.paddingMedium),
                        _buildPasswordField(),
                        const SizedBox(height: AppSizes.paddingMedium),
                        _buildRememberMeRow(),
                        const SizedBox(height: AppSizes.paddingLarge),
                        _buildLoginButton(),
                        const SizedBox(height: AppSizes.paddingMedium),
                        _buildForgotPasswordButton(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingLarge),

              // Alt bilgi
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryBlue),
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: const Color(AppColors.primaryBlue).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.engineering,
            size: AppSizes.iconXLarge * 1.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: AppSizes.textXXLarge * 1.2,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        const Text(
          'Endüstriyel Makine Kontrol Sistemi',
          style: TextStyle(
            fontSize: AppSizes.textMedium,
            color: Color(AppColors.grey500),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'E-posta',
        hintText: 'ornek@smartop.com',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: Color(AppColors.grey300)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(
            color: Color(AppColors.primaryBlue),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: Color(AppColors.errorRed)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'E-posta adresi gerekli';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Geçerli bir e-posta adresi girin';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: 'Şifre',
        hintText: 'Şifrenizi girin',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: Color(AppColors.grey300)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(
            color: Color(AppColors.primaryBlue),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: Color(AppColors.errorRed)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre gerekli';
        }
        if (value.length < 6) {
          return 'Şifre en az 6 karakter olmalı';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: const Color(AppColors.primaryBlue),
        ),
        const Text('Beni hatırla'),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: Implement forgot password
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Şifre sıfırlama yakında eklenecek...'),
              ),
            );
          },
          child: const Text(
            'Şifremi Unuttum',
            style: TextStyle(color: Color(AppColors.primaryBlue)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        elevation: 3,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Giriş Yap',
              style: TextStyle(
                fontSize: AppSizes.textLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return OutlinedButton(
      onPressed: () {
        // TODO: Navigate to register page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt sayfası yakında eklenecek...')),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(AppColors.primaryBlue),
        side: const BorderSide(color: Color(AppColors.primaryBlue)),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
      child: const Text(
        'Hesap Oluştur',
        style: TextStyle(
          fontSize: AppSizes.textLarge,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Test kullanıcıları bilgisi
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: const Color(AppColors.infoBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: const Color(AppColors.infoBlue).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: AppSizes.iconSmall,
                    color: const Color(AppColors.infoBlue),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  const Text(
                    'Test Kullanıcıları (Offline Mode)',
                    style: TextStyle(
                      color: Color(AppColors.infoBlue),
                      fontSize: AppSizes.textSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              const Text(
                'admin@smartop.com / 123456 (Admin)\noperator@smartop.com / 123456 (Operator)\nmanager@smartop.com / 123456 (Manager)',
                style: TextStyle(
                  color: Color(AppColors.grey700),
                  fontSize: AppSizes.textSmall,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.paddingMedium),

        const Text(
          'SmartOp Mobile v${AppConstants.appVersion}',
          style: TextStyle(
            color: Color(AppColors.grey500),
            fontSize: AppSizes.textSmall,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: AppSizes.iconSmall,
              color: const Color(AppColors.warningOrange),
            ),
            const SizedBox(width: AppSizes.paddingSmall / 2),
            const Text(
              'Offline Test Mode',
              style: TextStyle(
                color: Color(AppColors.grey500),
                fontSize: AppSizes.textSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
