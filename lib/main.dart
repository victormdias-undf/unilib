import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Frontend/Login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis do arquivo .env (URL e Publishable_Key).
  await dotenv.load(fileName: '.env');

  // Inicializa o Supabase; depois disso, Supabase.instance.client
  // fica disponível em todo o app (ex.: ProtocoloService).
  await Supabase.initialize(
    url: dotenv.env['URL']!,
    publishableKey: dotenv.env['Publishable_Key']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}
