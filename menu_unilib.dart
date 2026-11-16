
import 'package:flutter/material.dart';

class MenuUnilib extends StatelessWidget {
  final ValueChanged<String> aoSelecionar;

  const MenuUnilib({
    super.key,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.menu,
        color: Color(0xFF493A80),
        size: 28,
      ),

      onSelected: aoSelecionar,

      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'Biblioteca Geral',
          child: Text('Biblioteca Geral'),
        ),

        PopupMenuItem(
          value: 'Acervo dos Alunos',
          child: Text('Acervo dos Alunos'),
        ),

        PopupMenuItem(
          value: 'Fórum',
          child: Text('Fórum'),
        ),

        PopupMenuItem(
          value: 'Protocolo',
          child: Text('Protocolo'),
        ),

        PopupMenuItem(
          value: 'Meu Perfil',
          child: Text('Meu Perfil'),
        ),

        PopupMenuDivider(),

        PopupMenuItem(
          value: 'Sair',
          child: Text('Sair'),
        ),
      ],
    );
  }
}
