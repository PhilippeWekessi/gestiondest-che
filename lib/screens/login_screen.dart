import 'package:flutter/material.dart';

import '../services/auth_api_service.dart';
import '../services/auth_session.dart';
import '../theme/app_colors.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthSession session;
  final VoidCallback onLogin;

  const LoginScreen({super.key, required this.session, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthApiService(
        widget.session,
      ).login(_identifier.text.trim(), _password.text);
    } catch (error) {
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
      return;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (mounted) widget.onLogin();
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 60),
            const Text(
              'Gestion des Tâches',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Organise tes journées avec clarté.',
              style: TextStyle(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 44),
            _field(_identifier, 'Email ou numéro de téléphone', Icons.person_outline),
            const SizedBox(height: 14),
            _field(_password, 'Mot de passe', Icons.lock_outline, secret: true),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!, style: const TextStyle(color: AppColors.high)),
            ],
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _loading ? null : _login,
              child: Text(_loading ? 'Connexion...' : 'Se connecter'),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _loading
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterScreen(session: widget.session),
                        ),
                      );
                    },
              child: const Text("Créer un compte"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool secret = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: secret,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.paper,
      ),
    );
  }
}