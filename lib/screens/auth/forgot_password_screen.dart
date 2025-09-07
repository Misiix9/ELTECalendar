// File: lib/screens/auth/forgot_password_screen.dart
// Purpose: Password reset screen following specification
// Step: 2.2 - Password Reset Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../models/user_model.dart';
import '../../widgets/common_widgets/loading_overlay.dart';
import '../../widgets/common_widgets/custom_text_field.dart';
import '../../widgets/common_widgets/auth_button.dart';

/// Password reset screen with email validation
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ThemeConfig.primaryDarkBlue,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header section
                  _buildHeader(localizations),
                  
                  const SizedBox(height: 48),
                  
                  // Reset form
                  _buildResetForm(localizations),
                  
                  const SizedBox(height: 32),
                  
                  // Back to login link
                  _buildBackToLoginLink(localizations),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build header section
  Widget _buildHeader(AppLocalizations? localizations) {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ThemeConfig.goldAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset,
            color: ThemeConfig.primaryDarkBlue,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Title
        Text(
          'Reset Password',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: ThemeConfig.darkTextElements.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build reset form
  Widget _buildResetForm(AppLocalizations? localizations) {
    return Column(
      children: [
        // Email field
        CustomTextField(
          controller: _emailController,
          labelText: localizations?.email ?? 'Email Address',
          hintText: 'Enter your email address',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations?.getString('emailRequired') ?? 'Email is required';
            }
            if (!UserProfileValidator.isValidEmail(value.trim())) {
              return localizations?.getString('invalidEmail') ?? 'Invalid email format';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handlePasswordReset(),
        ),
        
        const SizedBox(height: 24),
        
        // Success message
        if (_successMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Error message
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Reset button
        AuthButton(
          text: 'Send Reset Link',
          onPressed: _isLoading ? null : _handlePasswordReset,
          isLoading: _isLoading,
          backgroundColor: ThemeConfig.primaryDarkBlue,
          textColor: ThemeConfig.lightBackground,
        ),
        
        const SizedBox(height: 16),
        
        // Resend button (only show after success)
        if (_successMessage != null) ...[
          AuthOutlineButton(
            text: 'Resend Email',
            onPressed: _isLoading ? null : _handlePasswordReset,
            borderColor: ThemeConfig.primaryDarkBlue,
            textColor: ThemeConfig.primaryDarkBlue,
          ),
        ],
      ],
    );
  }

  /// Build back to login link
  Widget _buildBackToLoginLink(AppLocalizations? localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
          style: TextStyle(
            color: ThemeConfig.darkTextElements.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            localizations?.login ?? 'Sign In',
            style: const TextStyle(
              color: ThemeConfig.primaryDarkBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Handle password reset request
  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final result = await authService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (result.success) {
        setState(() {
          _successMessage = 'Password reset email sent! Please check your inbox and follow the instructions to reset your password.';
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send reset email. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}