import 'package:flutter/material.dart';

import '../services/auth_api_service.dart';
import '../services/auth_session.dart';
import '../theme/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthSession session;
  final VoidCallback onLogin;

  const LoginScreen({super.key, required this.session, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
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
      ).login(_email.text.trim(), _password.text);
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
    _email.dispose();
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
              'Ziko',
              style: TextStyle(
                fontSize: 40,
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
            _field(_email, 'Email', Icons.email_outlined),
            const SizedBox(height: 14),
            _field(_password, 'Mot de passe', Icons.lock_outline, secret: true),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: const TextStyle(color: AppColors.high)),
            ],
            const SizedBox(height: 24),
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
