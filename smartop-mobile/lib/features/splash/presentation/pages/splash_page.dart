import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../auth/presentation/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Give a moment for splash screen to show
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      final authService = AuthService();
      await authService.init();

      if (authService.isLoggedIn) {
        // Navigate to dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      // On error, go to login
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.primaryBlue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.precision_manufacturing,
                size: AppSizes.iconXLarge * 1.5,
                color: Color(AppColors.primaryBlue),
              ),
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            // App Name
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: AppSizes.textXXLarge * 1.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: AppSizes.paddingSmall),

            // App Tagline
            const Text(
              'Endüstriyel Makine Kontrol Sistemi',
              style: TextStyle(
                fontSize: AppSizes.textMedium,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: AppSizes.paddingXLarge * 2),

            // Loading Indicator
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            // Loading Text
            const Text(
              'Yükleniyor...',
              style: TextStyle(
                fontSize: AppSizes.textMedium,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
