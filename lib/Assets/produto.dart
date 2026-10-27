class Produto {
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final String imagem;
  final String estado;
  final int quantidade;
  final bool emprestado;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imagem,
    required this.estado,
    required this.quantidade,
    required this.emprestado,
  });
}