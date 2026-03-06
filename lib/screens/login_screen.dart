import 'package:flutter/material.dart';
import 'package:triflouze/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/triflouze_logo.dart';
import '../theme/triflouze_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isRegistering = false;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      final result = await AuthService().signInWithGoogle();
      if (result == null && mounted) {
        setState(() => _error = l10n.errorGoogleCancelled);
      }
    } catch (e) {
      if (mounted) setState(() => _error = l10n.errorGoogle);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.errorEmptyFields);
      return;
    }
    if (_isRegistering && _displayNameController.text.trim().isEmpty) {
      setState(() => _error = l10n.errorEmptyFirstName);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = AuthService();
      if (_isRegistering) {
        await auth.register(email, password);
        await auth.updateDisplayName(_displayNameController.text.trim());
      } else {
        await auth.signIn(email, password);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = _friendlyError(e.toString(), AppLocalizations.of(context)!));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String error, AppLocalizations l10n) {
    if (error.contains('invalid-credential') ||
        error.contains('wrong-password') ||
        error.contains('user-not-found')) {
      return l10n.errorInvalidCredential;
    }
    if (error.contains('email-already-in-use')) return l10n.errorEmailInUse;
    if (error.contains('weak-password')) return l10n.errorWeakPassword;
    if (error.contains('invalid-email')) return l10n.errorInvalidEmail;
    return l10n.errorUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TriflouzeLogoVertical(iconSize: 88),
                const SizedBox(height: 40),
                Text(
                  _isRegistering ? l10n.registerTitle : l10n.loginTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TriflouzeTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isRegistering) ...[
                  TextField(
                    controller: _displayNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.firstNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isRegistering ? l10n.signUp : l10n.signIn,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() {
                    _isRegistering = !_isRegistering;
                    _error = null;
                  }),
                  child: Text(
                    _isRegistering ? l10n.switchToSignIn : l10n.switchToSignUp,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.orDivider,
                        style: const TextStyle(color: TriflouzeTheme.textMedium),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: (_loading || _googleLoading) ? null : _signInWithGoogle,
                    icon: _googleLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.g_mobiledata, size: 24),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        l10n.continueWithGoogle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
