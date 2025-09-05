// File: lib/screens/auth/login_screen.dart
// Purpose: Login screen stub for project initialization
// Step: 1.1 - Initialize Flutter Project

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';

/// Login screen - placeholder implementation
/// Will be fully implemented in Step 2: Authentication System
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo/title
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: ThemeConfig.primaryDarkBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  'ELTE Calendar',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: ThemeConfig.primaryDarkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: localizations?.email ?? 'Email',
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: localizations?.password ?? 'Password',
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(localizations?.login ?? 'Login'),
                ),
                const SizedBox(height: 16),
                
                // Register button
                OutlinedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: Text(localizations?.register ?? 'Register'),
                ),
                
                const SizedBox(height: 32),
                
                // Placeholder text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeConfig.goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ThemeConfig.goldAccent.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'Placeholder Login Screen\n\nAuthentication system will be implemented in Step 2.\n\nThis screen allows the app to compile and shows the theme configuration.',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeConfig.darkTextElements,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle login button press
  /// TODO: Implement actual authentication
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate login process
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Implement real authentication logic
    
    setState(() {
      _isLoading = false;
    });
  }

  /// Handle register button press
  /// TODO: Implement registration flow
  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate registration process
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Navigate to registration screen
    
    setState(() {
      _isLoading = false;
    });
  }
}