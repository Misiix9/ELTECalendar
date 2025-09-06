// File: lib/screens/auth/login_screen.dart
// Purpose: Complete login screen with full authentication functionality
// Step: 2.2 - Login Screen Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';
import '../../config/localization_config.dart';
import '../../models/user_model.dart';
import '../../widgets/common_widgets/loading_overlay.dart';
import '../../widgets/common_widgets/custom_text_field.dart';
import '../../widgets/common_widgets/auth_button.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// Complete login screen with authentication functionality
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _rememberMe = false;

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
                  const SizedBox(height: 60),
                  
                  // Header section
                  _buildHeader(localizations),
                  
                  const SizedBox(height: 48),
                  
                  // Login form
                  _buildLoginForm(localizations),
                  
                  const SizedBox(height: 32),
                  
                  // Social login buttons
                  _buildSocialLogin(localizations),
                  
                  const SizedBox(height: 24),
                  
                  // Create account link
                  _buildRegisterLink(localizations),
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
        
        // Welcome subtitle
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: ThemeConfig.darkTextElements.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build login form with validation
  Widget _buildLoginForm(AppLocalizations? localizations) {
    return Column(
      children: [
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
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
        ),
        
        const SizedBox(height: 12),
        
        // Remember me and forgot password row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remember me checkbox
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: ThemeConfig.primaryDarkBlue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                Text(
                  'Remember me',
                  style: TextStyle(
                    color: ThemeConfig.darkTextElements.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            // Forgot password link
            AuthTextButton(
              text: localizations?.forgotPassword ?? 'Forgot Password?',
              onPressed: _isLoading ? null : _navigateToForgotPassword,
              isUnderlined: true,
            ),
          ],
        ),
        
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
        
        // Login button
        AuthButton(
          text: localizations?.login ?? 'Sign In',
          onPressed: _isLoading ? null : _handleLogin,
          isLoading: _isLoading,
          backgroundColor: ThemeConfig.primaryDarkBlue,
          textColor: ThemeConfig.lightBackground,
        ),
      ],
    );
  }

  /// Build social login buttons
  Widget _buildSocialLogin(AppLocalizations? localizations) {
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

  /// Build register link
  Widget _buildRegisterLink(AppLocalizations? localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(
            color: ThemeConfig.darkTextElements.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _navigateToRegister,
          child: Text(
            localizations?.register ?? 'Create Account',
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

  /// Handle email/password login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final result = await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        // Login successful - navigation handled by auth state changes
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/calendar');
        }
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
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
          Navigator.of(context).pushReplacementNamed('/calendar');
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
          Navigator.of(context).pushReplacementNamed('/calendar');
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

  /// Navigate to registration screen
  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  /// Navigate to forgot password screen
  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }
}