import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/user_profile.dart';
import '../services/auth_api_service.dart';
import '../services/auth_session.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  final AuthSession session;
  const ProfileScreen({super.key, required this.session});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _photo;
  bool _saving = false;
  bool _photoError = false;

  @override
  void initState() {
    super.initState();
    final user = widget.session.user!;
    _name = TextEditingController(text: user.fullName);
    _phone = TextEditingController(text: user.phone);
    _email = TextEditingController(text: user.email);
    _photo = TextEditingController(text: user.photoUrl);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom et l’adresse email sont obligatoires.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthApiService(widget.session).updateProfile(
        UserProfile(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          photoUrl: _photo.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil mis à jour.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (image != null) {
      setState(() {
        _photo.text = image.path;
        _photoError = false;
      });
    }
  }

  ImageProvider<Object>? get _photoProvider {
    final value = _photo.text.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    final file = File(value);
    return file.existsSync() ? FileImage(file) : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _photo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.accentSoft,
                  backgroundImage: _photoProvider,
                  onBackgroundImageError: _photoProvider == null
                      ? null
                      : (_, _) => setState(() => _photoError = true),
                  child: _photoProvider == null || _photoError
                      ? Text(
                          _name.text.isEmpty
                              ? '?'
                              : _name.text[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 34,
                            color: AppColors.accent,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: -4,
                  bottom: -2,
                  child: IconButton.filled(
                    tooltip: 'Changer la photo',
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _field(_name, 'Nom complet', Icons.person_outline),
          const SizedBox(height: 12),
          _field(_phone, 'Téléphone', Icons.phone_outlined),
          const SizedBox(height: 12),
          _field(
            _email,
            'Email',
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppColors.paper,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
