import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen>
    with WidgetsBindingObserver {
  Timer? _checkTimer;
  bool _isResending = false;
  bool _isChecking = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startVerificationCheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check immediately when user comes back from email app
    if (state == AppLifecycleState.resumed) {
      _checkVerification();
    }
  }

  void _startVerificationCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerification();
    });
  }

  Future<void> _checkVerification() async {
    final authService = ref.read(authServiceProvider);
    await authService.reloadUser();
    final user = authService.currentUser;
    if (user != null && user.emailVerified) {
      _checkTimer?.cancel();
      await authService.updateEmailVerifiedStatus();
      // userChanges() stream in AuthWrapper will detect the reload and navigate
    }
  }

  Future<void> _manualCheck() async {
    setState(() => _isChecking = true);
    await _checkVerification();
    final user = ref.read(authServiceProvider).currentUser;
    if (mounted && (user == null || !user.emailVerified)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email not verified yet. Please check your inbox.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
    if (mounted) setState(() => _isChecking = false);
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      if (!mounted) return;
      setState(() => _emailSent = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _emailSent = false);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not resend email. Try again later.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = ref.watch(currentUserProvider)?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Verify Your Email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We sent a verification link to',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Open your email and tap the link to verify your account.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isChecking ? null : _manualCheck,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _isChecking ? 'Checking...' : "I've Verified My Email",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_emailSent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Verification email resent!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _isResending ? null : _resendEmail,
                icon: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(_isResending ? 'Sending...' : 'Resend Email'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                },
                child: Text(
                  'Use a different account',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
