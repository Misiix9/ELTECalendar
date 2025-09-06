// File: lib/widgets/common_widgets/auth_wrapper.dart
// Purpose: Authentication wrapper to handle auth state changes
// Step: 2.2 - Authentication Flow Implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../config/theme_config.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/calendar/calendar_main_screen.dart';
import '../../screens/auth/email_verification_screen.dart';

/// Authentication wrapper that routes users based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Show loading while checking authentication state
        if (authService.authState == UserAuthState.unknown) {
          return const AuthLoadingScreen();
        }

        // Route based on authentication state
        switch (authService.authState) {
          case UserAuthState.authenticated:
            return const CalendarMainScreen();
          
          case UserAuthState.emailNotVerified:
            return const EmailVerificationScreen();
          
          case UserAuthState.unauthenticated:
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

/// Loading screen shown during authentication initialization
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryDarkBlue,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConfig.primaryDarkBlue.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_today,
                color: ThemeConfig.lightBackground,
                size: 48,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App title
            Text(
              'ELTE Calendar',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: ThemeConfig.primaryDarkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: ThemeConfig.goldAccent,
              strokeWidth: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Loading text
            Text(
              'Initializing...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: ThemeConfig.darkTextElements.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown when authentication initialization fails
class AuthErrorScreen extends StatelessWidget {
  final String? error;
  
  const AuthErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Error title
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Error message
              Text(
                error ?? 'Failed to initialize authentication system. Please try again.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ThemeConfig.darkTextElements.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Retry button
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  Navigator.of(context).pushReplacementNamed('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primaryDarkBlue,
                  foregroundColor: ThemeConfig.lightBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Authentication guard for protected routes
class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isAuthenticated) {
          return child;
        } else {
          return fallback ?? const LoginScreen();
        }
      },
    );
  }
}

/// User info widget for displaying current user information
class UserInfoWidget extends StatelessWidget {
  final bool showAvatar;
  final bool showName;
  final bool showEmail;

  const UserInfoWidget({
    super.key,
    this.showAvatar = true,
    this.showName = true,
    this.showEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        
        if (user == null) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            if (showAvatar) ...[
              CircleAvatar(
                radius: 20,
                backgroundColor: ThemeConfig.goldAccent,
                backgroundImage: user.profileImageUrl != null 
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        user.displayName.isNotEmpty 
                            ? user.displayName[0].toUpperCase()
                            : user.email[0].toUpperCase(),
                        style: const TextStyle(
                          color: ThemeConfig.darkTextElements,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
            ],
            
            // User info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display name
                if (showName) ...[
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      color: ThemeConfig.darkTextElements,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showEmail) const SizedBox(height: 2),
                ],
                
                // Email
                if (showEmail) ...[
                  Text(
                    user.email,
                    style: TextStyle(
                      color: ThemeConfig.darkTextElements.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Logout button widget
class LogoutButton extends StatelessWidget {
  final bool showConfirmation;
  final String? customText;
  final IconData? customIcon;

  const LogoutButton({
    super.key,
    this.showConfirmation = true,
    this.customText,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return IconButton(
          icon: Icon(
            customIcon ?? Icons.logout,
            color: ThemeConfig.primaryDarkBlue,
          ),
          onPressed: () => _handleLogout(context, authService),
          tooltip: customText ?? 'Logout',
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthService authService) async {
    if (showConfirmation) {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (shouldLogout != true) return;
    }

    await authService.signOut();
  }
}