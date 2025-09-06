// File: lib/screens/auth/email_verification_screen.dart
// Purpose: Email verification screen (non-blocking as specified)
// Step: 2.2 - Email Verification Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../widgets/common_widgets/auth_button.dart';

/// Email verification screen - non-blocking as specified
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  String? _message;
  bool _canResend = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header section
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // Email info
              if (user != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeConfig.goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeConfig.goldAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: ThemeConfig.primaryDarkBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification email sent to:',
                              style: TextStyle(
                                color: ThemeConfig.darkTextElements.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: ThemeConfig.primaryDarkBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
              
              // Message display
              if (_message != null) ...[
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
                          _message!,
                          style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Action buttons
              _buildActionButtons(localizations),
              
              const SizedBox(height: 24),
              
              // Skip verification note (non-blocking as specified)
              _buildSkipOption(localizations),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
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
            Icons.mark_email_unread_outlined,
            color: ThemeConfig.primaryDarkBlue,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Title
        Text(
          'Verify Your Email',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Description
        Text(
          'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: ThemeConfig.darkTextElements.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(AppLocalizations? localizations) {
    return Column(
      children: [
        // Check verification status button
        AuthButton(
          text: 'I\'ve Verified My Email',
          onPressed: _handleCheckVerification,
          backgroundColor: ThemeConfig.primaryDarkBlue,
          textColor: ThemeConfig.lightBackground,
        ),
        
        const SizedBox(height: 12),
        
        // Resend email button
        AuthOutlineButton(
          text: _canResend 
              ? 'Resend Verification Email'
              : 'Resend in ${_resendCooldown}s',
          onPressed: _canResend && !_isResending ? _handleResendVerification : null,
          isLoading: _isResending,
          borderColor: ThemeConfig.primaryDarkBlue,
          textColor: ThemeConfig.primaryDarkBlue,
        ),
      ],
    );
  }

  /// Build skip option (non-blocking as specified)
  Widget _buildSkipOption(AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeConfig.primaryDarkBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Email verification is optional',
            style: TextStyle(
              color: ThemeConfig.darkTextElements,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can continue using the app without verifying your email. However, some features may be limited until verification is complete.',
            style: TextStyle(
              color: ThemeConfig.darkTextElements.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AuthTextButton(
            text: 'Continue to App',
            onPressed: _handleSkipVerification,
            textColor: ThemeConfig.primaryDarkBlue,
            isUnderlined: true,
          ),
        ],
      ),
    );
  }

  /// Handle checking verification status
  Future<void> _handleCheckVerification() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      // Reload the current user to check verification status
      await authService.firebaseUser?.reload();
      
      if (authService.firebaseUser?.emailVerified == true) {
        // Email is verified - navigate to main app
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/calendar');
        }
      } else {
        // Still not verified
        setState(() {
          _message = 'Email not yet verified. Please check your inbox and click the verification link.';
        });
        
        // Clear message after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _message = null;
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error checking verification status. Please try again.';
      });
    }
  }

  /// Handle resending verification email
  Future<void> _handleResendVerification() async {
    setState(() {
      _isResending = true;
      _message = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final result = await authService.sendEmailVerification();
      
      setState(() {
        _message = result.success 
            ? 'Verification email sent successfully!'
            : result.message;
      });
      
      if (result.success) {
        _startCooldown();
      }
    } catch (e) {
      setState(() {
        _message = 'Failed to send verification email. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  /// Handle skipping email verification (non-blocking as specified)
  void _handleSkipVerification() {
    Navigator.of(context).pushReplacementNamed('/calendar');
  }

  /// Start resend cooldown timer
  void _startCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60; // 60 seconds cooldown
    });

    // Update countdown every second
    Future.doWhile(() async {
      if (!mounted) return false;
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _resendCooldown--;
        });
        
        if (_resendCooldown <= 0) {
          setState(() {
            _canResend = true;
          });
          return false;
        }
      }
      
      return mounted;
    });
  }
}