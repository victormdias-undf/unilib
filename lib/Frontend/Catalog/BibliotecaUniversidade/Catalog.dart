import 'package:flutter/material.dart';

class BibliotecaPage extends StatelessWidget {
  const BibliotecaPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFD8D6FF);
    const Color secondaryColor = Color(0xFF6650A4);
    const Color placeholderColor = Color(0xFFA7A1A1);
 
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,

        title: const Text(
          "UniLib",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: secondaryColor,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Menu selecionado"),
                ),
              );
            },
            icon: const Icon(
              Icons.menu,
              color: secondaryColor,
              size: 30,
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: Column(
        children: [
          // Barra de pesquisa e filtro
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F2F7),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),

            child: Row(
              children: [
                const SizedBox(width: 12),

                Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 20,
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Pesquisar...",
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                Container(
                  width: 1,
                  height: double.infinity,
                  color: Colors.grey.shade400,
                ),

                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return const SafeArea(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Opções de filtro",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },

                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),

                  child: const Text(
                    "Filtro",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de categorias
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 16,
              ),

              children: [
                _buildCategory(
                  "Livros",
                  placeholderColor,
                ),

                _buildCategory(
                  "Eletrônicos",
                  placeholderColor,
                ),

                _buildCategory(
                  "Itens Gerais",
                  placeholderColor,
                ),

                _buildCategory(
                  "Salas",
                  placeholderColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCategory(String title, Color placeholderColor) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),

            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 5),

          SizedBox(
            height: 200,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              itemCount: 10,

              itemBuilder: (context, index) {
                return _item("assets/teste.jpeg", "item Legall", 1);
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _item(String imagePath, String title, int id){
    return SizedBox(
      width: 150,
      height: 200,
      child:Padding(padding: EdgeInsetsGeometry.all(5),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 170, 177, 179)
        ),
        child: Center(
          child: Column(
          children: [
            Container(width: 150, height: 170, decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(imagePath))
              ),
            ),
            Text(title)
            

          ],
        ),
        )
      ),
      )
    );
  }
}