import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../services/supabase_auth_service.dart';
import '../components/cd_atmospheric_background.dart';
import '../components/cd_glass_card.dart';
import '../components/cd_logo.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_text_input.dart';

/// Branded authentication screen providing seamless Sign In and Sign Up flows.
class AuthScreen extends StatefulWidget {
  final bool initialIsSignUp;

  const AuthScreen({
    super.key,
    this.initialIsSignUp = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isSignUp;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    AppHaptics.light();
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    if (_isSignUp && name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your creator or display name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = AppState.instance;
      if (_isSignUp) {
        await appState.signUp(
          email: email,
          password: password,
          displayName: name,
        );
      } else {
        await appState.signIn(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSignUp ? 'Account created successfully! ✦' : 'Welcome back! ✦'),
          backgroundColor: CDColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e is AuthServiceException ? e.message : SupabaseAuthService.mapAuthError(e);
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: CDAtmosphericBackground(
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg, vertical: CDSpacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Monogram Header
                    Container(
                      padding: const EdgeInsets.all(CDSpacing.lg),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CDColors.brand.withValues(alpha: isDark ? 0.30 : 0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const CDLogo.monogram(
                        height: 48,
                        colorMode: CDLogoColorMode.adaptive,
                      ),
                    ),
                    const SizedBox(height: CDSpacing.md),
                    Text(
                      _isSignUp ? 'Create Studio Account' : 'Sign In to CreateDiff',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: CDColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp
                          ? 'Unlock cloud identity, persistent profiles, and generation quotas.'
                          : 'Access your persistent creator identity and generation history.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CDColors.textSecondary(context),
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: CDSpacing.xl),

                    // Auth Form Glass Card
                    CDGlassCard(
                      elevated: true,
                      padding: const EdgeInsets.all(CDSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isSignUp) ...[
                            CDTextInput(
                              controller: _nameController,
                              label: 'Display Name',
                              hint: 'e.g. Alex Creator',
                              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                            ),
                            const SizedBox(height: CDSpacing.md),
                          ],
                          CDTextInput(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'creator@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                          ),
                          const SizedBox(height: CDSpacing.md),
                          CDTextInput(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: CDSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(CDSpacing.sm),
                              decoration: BoxDecoration(
                                color: CDColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(CDRadius.small),
                                border: Border.all(color: CDColors.error.withValues(alpha: 0.35)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 16, color: CDColors.error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: CDColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: CDSpacing.xl),
                          CDPrimaryButton(
                            label: _isSignUp ? 'Create Account ✦' : 'Sign In ✦',
                            isFullWidth: true,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: CDSpacing.lg),

                    // Toggle between sign in and sign up
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? 'Already have an account?' : "Don't have an account?",
                          style: TextStyle(
                            fontSize: 13,
                            color: CDColors.textSecondary(context),
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _toggleMode,
                          child: Text(
                            _isSignUp ? 'Sign In' : 'Create Account',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: CDColors.primaryColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
