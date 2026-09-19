import 'package:flutter/material.dart';
import 'services/auth_session.dart';
import 'screens/login_screen.dart';
import 'screens/task_list_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const ZikoApp());
}

class ZikoApp extends StatelessWidget {
  const ZikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Tâches',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          primary: AppColors.accent,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthSession _session = AuthSession();
  late final Future<void> _loadSession = _session.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (_session.isAuthenticated) {
          return TaskListScreen(
            session: _session,
            onLogout: () => setState(() {}),
          );
        }
        return LoginScreen(session: _session, onLogin: () => setState(() {}));
      },
    );
  }
}
