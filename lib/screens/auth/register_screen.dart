// File: lib/screens/auth/register_screen.dart
// Purpose: Registration screen with validation following specification
// Step: 2.2 - Registration Screen Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../models/user_model.dart';
import '../../widgets/common_widgets/loading_overlay.dart';
import '../../widgets/common_widgets/custom_text_field.dart';
import '../../widgets/common_widgets/auth_button.dart';

/// Registration screen with comprehensive validation and error handling
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
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
                  
                  // Registration form
                  _buildRegistrationForm(localizations),
                  
                  const SizedBox(height: 32),
                  
                  // Social registration buttons
                  _buildSocialRegistration(localizations),
                  
                  const SizedBox(height: 24),
                  
                  // Already have account link
                  _buildLoginLink(localizations),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build header section with app branding
  Widget _buildHeader(AppLocalizations? localizations) {
    return Column(
      children: [
        // App icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ThemeConfig.primaryDarkBlue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ThemeConfig.primaryDarkBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_today,
            color: ThemeConfig.lightBackground,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // App title
        Text(
          'ELTE Calendar',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: ThemeConfig.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Registration subtitle
        Text(
          localizations?.register ?? 'Create Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: ThemeConfig.darkTextElements.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build registration form with validation
  Widget _buildRegistrationForm(AppLocalizations? localizations) {
    return Column(
      children: [
        // Display name field
        CustomTextField(
          controller: _displayNameController,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            if (!UserProfileValidator.isValidDisplayName(value.trim())) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        
        const SizedBox(height: 16),
        
        // Email field
        CustomTextField(
          controller: _emailController,
          labelText: localizations?.email ?? 'Email',
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
          textInputAction: TextInputAction.next,
        ),
        
        const SizedBox(height: 16),
        
        // Password field
        CustomTextField(
          controller: _passwordController,
          labelText: localizations?.password ?? 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icons.lock,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: ThemeConfig.primaryDarkBlue.withOpacity(0.6),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations?.getString('passwordRequired') ?? 'Password is required';
            }
            if (!UserProfileValidator.isValidPassword(value)) {
              return localizations?.getString('passwordTooShort') ?? 'Password must be at least 6 characters';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        
        const SizedBox(height: 16),
        
        // Confirm password field
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: localizations?.confirmPassword ?? 'Confirm Password',
          hintText: 'Confirm your password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: ThemeConfig.primaryDarkBlue.withOpacity(0.6),
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleRegistration(),
        ),
        
        const SizedBox(height: 8),
        
        // Password requirements
        _buildPasswordRequirements(),
        
        const SizedBox(height: 24),
        
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
        
        // Register button
        AuthButton(
          text: localizations?.register ?? 'Create Account',
          onPressed: _isLoading ? null : _handleRegistration,
          isLoading: _isLoading,
          backgroundColor: ThemeConfig.primaryDarkBlue,
          textColor: ThemeConfig.lightBackground,
        ),
      ],
    );
  }

  /// Build password requirements indicator
  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
    final isLengthValid = password.length >= 6;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeConfig.goldAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeConfig.goldAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ThemeConfig.darkTextElements,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          _buildRequirementItem('At least 6 characters', isLengthValid),
        ],
      ),
    );
  }

  /// Build individual requirement item
  Widget _buildRequirementItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isValid ? Colors.green : ThemeConfig.darkTextElements.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : ThemeConfig.darkTextElements.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build social registration buttons
  Widget _buildSocialRegistration(AppLocalizations? localizations) {
    return Column(
      children: [
        // Divider with "or"
        Row(
          children: [
            Expanded(
              child: Divider(
                color: ThemeConfig.darkTextElements.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(
                  color: ThemeConfig.darkTextElements.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: ThemeConfig.darkTextElements.withOpacity(0.3),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Google Sign-In button
        AuthButton(
          text: localizations?.signInWithGoogle ?? 'Continue with Google',
          onPressed: _isLoading ? null : _handleGoogleSignIn,
          backgroundColor: Colors.white,
          textColor: ThemeConfig.darkTextElements,
          icon: Icons.g_mobiledata,
          hasBorder: true,
        ),
        
        const SizedBox(height: 12),
        
        // Apple Sign-In button (iOS only)
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          AuthButton(
            text: localizations?.signInWithApple ?? 'Continue with Apple',
            onPressed: _isLoading ? null : _handleAppleSignIn,
            backgroundColor: ThemeConfig.darkTextElements,
            textColor: ThemeConfig.lightBackground,
            icon: Icons.apple,
          ),
        ],
      ],
    );
  }

  /// Build login link
  Widget _buildLoginLink(AppLocalizations? localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
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

  /// Handle email/password registration
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final result = await authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );

      if (result.success) {
        // Registration successful - navigate to calendar or show verification screen
        if (mounted) {
          _showRegistrationSuccess();
        }
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final result = await authService.signInWithGoogle();

      if (result.success) {
        // Google sign-in successful - navigation handled by auth state changes
        if (mounted) {
          _showRegistrationSuccess();
        }
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign-in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle Apple Sign-In
  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final result = await authService.signInWithApple();

      if (result.success) {
        // Apple sign-in successful - navigation handled by auth state changes
        if (mounted) {
          _showRegistrationSuccess();
        }
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Apple sign-in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show registration success message
  void _showRegistrationSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Registration Successful!'),
          ],
        ),
        content: const Text(
          'Your account has been created successfully. You can now start using ELTE Calendar to manage your course schedules.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacementNamed('/calendar');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryDarkBlue,
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}