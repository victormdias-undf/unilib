import 'menu_unilib.dart';
import 'package:flutter/material.dart';

class PaginaAcervoAlunos extends StatefulWidget {
  final ValueChanged<String> aoSelecionarMenu;

  const PaginaAcervoAlunos({
    super.key,
    required this.aoSelecionarMenu,
  });

  @override
  State<PaginaAcervoAlunos> createState() =>
      _PaginaAcervoAlunosState();
}

class _PaginaAcervoAlunosState
    extends State<PaginaAcervoAlunos> {

  String pesquisa = '';

  // Itens fictícios para testar a interface.
  // Futuramente serão carregados do banco de dados.
  final List<String> itens = List.generate(
    12,
    (numero) => 'Item ${numero + 1}',
  );

  @override
  Widget build(BuildContext context) {

    // Pesquisa os itens pelo nome.
    final itensFiltrados = itens.where((item) {
      return item.toLowerCase().contains(
        pesquisa.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      // CABEÇALHO
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCD9FF),

        iconTheme: const IconThemeData(
          color: Color(0xFF493A80),
        ),

        title: Image.asset(
  'imagens/logo_unilib.png',
  width: 95,
  height: 38,
  fit: BoxFit.contain,
),

actions: [
  MenuUnilib(
    aoSelecionar: widget.aoSelecionarMenu,
  ),
  const SizedBox(width: 8),
],

),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // TÍTULO
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Text(
              'Acervo dos Alunos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // BARRA DE PESQUISA
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (texto) {
                setState(() {
                  pesquisa = texto;
                });
              },

              decoration: InputDecoration(
                hintText: 'Pesquisar item...',
                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: const Color(0xFFF2F2F6),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // TODOS OS ITENS JUNTOS
          Expanded(
            child: itensFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum item encontrado.',
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, tamanho) {

                      final colunas =
                          tamanho.maxWidth < 450 ? 2 :
                          tamanho.maxWidth < 900 ? 3 : 4;

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),

                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: colunas,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 180,
                        ),

                        itemCount: itensFiltrados.length,

                        itemBuilder: (context, indice) {

                          final nome = itensFiltrados[indice];

                          return InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Detalhes de $nome em breve!',
                                  ),
                                ),
                              );
                            },

                            child: Column(
                              children: [

                                // IMAGEM DO ITEM
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAAA6A6),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // NOME DO ITEM
                                Text(
                                  nome,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // STATUS ILUSTRATIVO
                                const Text(
                                  'Disponível',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
