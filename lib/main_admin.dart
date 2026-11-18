import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'PainelAdm/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdminEntry());
}

class AdminEntry extends StatelessWidget {
  const AdminEntry({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFF6F4FF),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const Card(
                margin: EdgeInsets.all(24),
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language, size: 48, color: Color(0xFF6650A4)),
                      SizedBox(height: 16),
                      Text(
                        'Acesso apenas via web',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F1B2E),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'O painel administrativo da UniLib está disponível somente pelo navegador.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6B657A)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const AdminApp();
  }
}
