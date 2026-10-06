import 'package:flutter/material.dart';

class BibliotecaPage extends StatelessWidget {
  const BibliotecaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8D6FF),
        title: const Text(
          "UniLib",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6650A4),
          ),
        ),
        actions: [
          
        ],
      ),
      body: const Center(
        child: Text("Conteúdo"),
      ),
    );
  }
}