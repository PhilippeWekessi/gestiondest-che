import 'package:flutter/material.dart';

import '../services/auth_api_service.dart';
import '../services/auth_session.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  final AuthSession session;
  const RegisterScreen({super.key, required this.session});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthApiService(widget.session).register(
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _field(_name, 'Nom complet'),
          const SizedBox(height: 12),
          _field(_phone, 'Téléphone'),
          const SizedBox(height: 12),
          _field(_email, 'Email'),
          const SizedBox(height: 12),
          _field(_password, 'Mot de passe', secret: true),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.high)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _register,
            child: Text(_loading ? 'Inscription...' : "S'inscrire"),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool secret = false,
  }) => TextField(
    controller: controller,
    obscureText: secret,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.paper,
    ),
  );
}
