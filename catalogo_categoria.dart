
import 'package:flutter/material.dart';

class PaginaCatalogoCategoria extends StatefulWidget {
  final String categoria;

  const PaginaCatalogoCategoria({
    super.key,
    required this.categoria,
  });

  @override
  State<PaginaCatalogoCategoria> createState() =>
      _PaginaCatalogoCategoriaState();
}

class _PaginaCatalogoCategoriaState
    extends State<PaginaCatalogoCategoria> {

  String pesquisa = '';

  @override
  Widget build(BuildContext context) {

    // Itens de exemplo.
    // Futuramente virão do banco de dados.
  
final quantidade = widget.categoria == 'Salas'
    ? 4
    : widget.categoria == 'Eletrônicos'
        ? 6
        : 18;

final itens = List.generate(
  quantidade,
  (numero) => '${widget.categoria} ${numero + 1}',
);


    // Filtra os itens pelo nome.
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

        title: Row(
          children: [
            Image.asset(
              'imagens/logo_unilib.png',
              width: 85,
              height: 35,
              fit: BoxFit.contain,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                widget.categoria,
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF493A80),
                ),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          // campo pesquisa
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (texto) {
                setState(() {
                  pesquisa = texto;
                });
              },

              decoration: InputDecoration(
                hintText: 'Pesquisar ${widget.categoria}...',
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

          // aviso sobre itens
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Itens ilustrativos para teste',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),

          // lista de itens
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
                          tamanho.maxWidth < 600 ? 3 : 4;

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
                                      color: const Color.fromARGB(255, 223, 198, 195),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                // NOME
                                Text(
                                  nome,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                // DISPONIBILIDADE DE EXEMPLO
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
