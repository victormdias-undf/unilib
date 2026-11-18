import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/login_admin_page.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniLib - Painel Administrativo',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.theme,
      home: const LoginAdminPage(),
    );
  }
}
