import 'package:flutter/material.dart';
import '../../../Assets/produto.dart';
class ProdutoPage extends StatefulWidget {
  final Produto produto;
  const ProdutoPage({super.key, required this.produto});

  @override
  State<ProdutoPage> createState() => _ProdutoPageState();
}

class _ProdutoPageState extends State<ProdutoPage> {
  bool estaFavoritado = false;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFD8D6FF);
    const Color secondaryColor = Color(0xFF6650A4);
    const String titleFont = "Irish";
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Produto",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: secondaryColor,
            fontFamily: titleFont
          ),
        ),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.produto.nome,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Image(image: AssetImage(widget.produto.imagem)),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.produto.descricao,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.produto.estado,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight(600)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Quantidade: ${widget.produto.quantidade}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight(600)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Disponível: ${widget.produto.emprestado ? "Não" : "Sim"}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight(600)),
                    ),
                    
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          estaFavoritado = !estaFavoritado;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Favoritar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            estaFavoritado ? Icons.star : Icons.star_border,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: secondaryColor,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text("Reservar"),
                      ),
                    ),
                    SizedBox(height: 80,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
