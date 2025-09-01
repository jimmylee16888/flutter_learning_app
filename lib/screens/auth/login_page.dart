// lib/screens/auth/login_page.dart
import 'package:flutter/material.dart';
import '../../services/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.auth});
  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo or Placeholder
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: color.primary.withOpacity(0.12),
                    child: Icon(Icons.style, size: 48, color: color.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '歡迎使用小卡管理',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '登入以在裝置間同步設定與資料（僅使用 Google 基本公開資訊）',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Google Sign in button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: auth.isLoading ? null : auth.signInWithGoogle,
                      icon: auth.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        auth.isLoading ? '登入中…' : '使用 Google 登入',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Continue as guest
                  TextButton(
                    onPressed: auth.isLoading ? null : auth.continueAsGuest,
                    child: const Text('先略過，稍後再登入'),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    '登入後可在設定頁面登出或切換帳號',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
