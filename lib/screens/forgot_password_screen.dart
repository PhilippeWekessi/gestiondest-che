import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _sendLink() {
    if (_email.text.trim().isEmpty) return;
    setState(() => _sent = true);
    // Pas encore branché sur une vraie route Laravel de réinitialisation —
    // à faire quand tu avanceras sur cette partie.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Entre ton e-mail, on t'enverra un lien de réinitialisation.",
              style: TextStyle(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: AppColors.paper,
              ),
            ),
            if (_sent) ...[
              const SizedBox(height: 14),
              const Text(
                'Si un compte existe avec cet e-mail, un lien a été envoyé.',
                style: TextStyle(color: AppColors.low),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _sendLink, child: const Text('Envoyer le lien')),
          ],
        ),
      ),
    );
  }
}