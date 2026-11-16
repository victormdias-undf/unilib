import 'package:flutter/material.dart';

import 'acervo_alunos.dart';
import 'catalogo_categoria.dart';
import 'menu_unilib.dart';

class PaginaBibliotecaGeral extends StatefulWidget {
  final VoidCallback aoSair;

  const PaginaBibliotecaGeral({
    super.key,
    required this.aoSair,
  });

  @override
  State<PaginaBibliotecaGeral> createState() =>
      _PaginaBibliotecaGeralState();
}

class _PaginaBibliotecaGeralState extends State<PaginaBibliotecaGeral> {
  final TextEditingController _pesquisa = TextEditingController();
  String _filtro = 'Todos';

  final List<String> _categorias = [
    'Livros',
    'Eletrônicos',
    'Itens Gerais',
    'Salas',
  ];

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  // Mostra uma mensagem breve ao usuário.
  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Navegação do menu, compartilhada com o Acervo dos Alunos.
  void _abrirPagina(String pagina) {
    final navegador = Navigator.of(context);

    if (pagina == 'Biblioteca Geral') {
      navegador.popUntil((rota) => rota.isFirst);
      return;
    }

    if (pagina == 'Acervo dos Alunos') {
      navegador.popUntil((rota) => rota.isFirst);
      navegador.push(
        MaterialPageRoute(
          builder: (context) => PaginaAcervoAlunos(
            aoSelecionarMenu: _abrirPagina,
          ),
        ),
      );
      return;
    }

    if (pagina == 'Sair') {
      navegador.popUntil((rota) => rota.isFirst);
      widget.aoSair();
      return;
    }

    _mostrarMensagem('$pagina será desenvolvida em breve!');
  }

  // Cartões de exemplo até a integração com o banco de dados.
  Widget _cartao(String categoria, int numero) {
    return Expanded(
      child: InkWell(
        onTap: () {
          _mostrarMensagem('Detalhes do item serão adicionados depois.');
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 115,
                decoration: BoxDecoration(
                  color: const Color(0xFFAAA6A6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$categoria $numero',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Disponível',
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Exibe três itens de cada categoria e uma seta para o catálogo completo.
  Widget _secao(String categoria) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoria,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _cartao(categoria, 1),
              _cartao(categoria, 2),
              _cartao(categoria, 3),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginaCatalogoCategoria(
                        categoria: categoria,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriasVisiveis = _categorias.where((categoria) {
      final texto = _pesquisa.text.toLowerCase();
      final correspondePesquisa = categoria.toLowerCase().contains(texto);
      final correspondeFiltro = _filtro == 'Todos' || _filtro == categoria;
      return correspondePesquisa && correspondeFiltro;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCD9FF),
        automaticallyImplyLeading: false,
        title: Image.asset(
          'imagens/logo_unilib.png',
          width: 95,
          height: 38,
          fit: BoxFit.contain,
        ),
        actions: [
          MenuUnilib(aoSelecionar: _abrirPagina),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesquisa,
                    onChanged: (texto) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F6),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (valor) => setState(() => _filtro = valor),
                  itemBuilder: (context) => [
                    for (final categoria in ['Todos', ..._categorias])
                      PopupMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    color: const Color(0xFFEDEDF2),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Filtro'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: categoriasVisiveis.isEmpty
                ? const Center(child: Text('Nenhuma categoria encontrada.'))
                : ListView(
                    children: [
                      for (final categoria in categoriasVisiveis)
                        _secao(categoria),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
