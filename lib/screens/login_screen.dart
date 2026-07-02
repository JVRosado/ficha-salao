import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../utils/api_client.dart';
import '../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiClient.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (mounted) context.go('/');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Fichas de Anamnese',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppTheme.slate800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entre com sua conta do salão',
                    style: TextStyle(fontSize: 15, color: AppTheme.slate600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  const FieldLabel('Email'),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'seuemail@exemplo.com'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Senha'),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    onSubmitted: (_) => _loading ? null : _login(),
                    decoration: const InputDecoration(hintText: '••••••••'),
                    style: const TextStyle(fontSize: 16),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ],

                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: _loading ? 'Entrando...' : 'Entrar',
                    icon: Icons.login,
                    onPressed: _loading ? () {} : _login,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
