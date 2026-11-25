import 'package:flutter/material.dart';
import '../theme.dart';
import 'admin_shell.dart';

class LoginAdminPage extends StatefulWidget {
  const LoginAdminPage({super.key});

  @override
  State<LoginAdminPage> createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage> {
  final _identificacaoController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _identificacaoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _entrar() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE9E6FF), Color(0xFFF6F4FF), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'UniLib',
                    style: TextStyle(
                      fontSize: 54,
                      fontFamily: AdminTheme.titleFont,
                      fontWeight: FontWeight.w700,
                      color: AdminTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Painel Administrativo da Biblioteca',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AdminTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AdminTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  color: AdminTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Acesso da biblioteca',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AdminTheme.text,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Entre com as credenciais institucionais para gerenciar o acervo e a comunidade.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AdminTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _identificacaoController,
                            decoration: const InputDecoration(
                              labelText: 'Identificação da biblioteca',
                              hintText: 'E-mail ou código institucional',
                              prefixIcon: Icon(Icons.account_balance_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _senhaController,
                            obscureText: !_showPass,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              hintText: 'Insira sua senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPass ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () => setState(() => _showPass = !_showPass),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Recuperação de acesso em breve.'),
                                  ),
                                );
                              },
                              child: const Text('Esqueci minha senha'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _entrar,
                              icon: const Icon(Icons.login),
                              label: const Text('Entrar no painel'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Acesso restrito à equipe da biblioteca universitária.',
                    style: TextStyle(fontSize: 12, color: AdminTheme.textMuted),
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
