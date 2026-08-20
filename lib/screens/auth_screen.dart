import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../config/supabase_config.dart';
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
                          if (!SupabaseConfig.isConfigured) ...[
                            Container(
                              padding: const EdgeInsets.all(CDSpacing.md),
                              decoration: BoxDecoration(
                                color: CDColors.surfaceElevated(context),
                                borderRadius: BorderRadius.circular(CDRadius.medium),
                                border: Border.all(color: CDColors.brand.withValues(alpha: 0.4), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.cloud_off_rounded, size: 20, color: CDColors.brand),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Offline Studio Mode Active',
                                          style: TextStyle(
                                            color: CDColors.textPrimary(context),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Cloud authentication is unconfigured in this build. Local Creator Memory, saved drafts, and AI generation remain fully operational.',
                                          style: TextStyle(
                                            color: CDColors.textSecondary(context),
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: CDSpacing.md),
                          ],
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
                              padding: const EdgeInsets.all(CDSpacing.md),
                              decoration: BoxDecoration(
                                color: CDColors.surfaceElevated(context),
                                borderRadius: BorderRadius.circular(CDRadius.medium),
                                border: Border.all(color: CDColors.error.withValues(alpha: 0.5), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: CDColors.error.withValues(alpha: isDark ? 0.25 : 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 20, color: CDColors.error),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Authentication Notice',
                                          style: TextStyle(
                                            color: CDColors.error,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: CDColors.textPrimary(context),
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
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
