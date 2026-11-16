/// Exceção HTTP de domínio. Nunca inclui dados privados no corpo da API.
class ErroApi implements Exception {
  final int status;
  final String mensagem;
  final String codigo;

  const ErroApi(this.status, this.mensagem, [this.codigo = 'erro_requisicao']);

  @override
  String toString() => 'ErroApi($status, $codigo): $mensagem';
}

/// Nomes oficiais utilizados pelo frontend, API e banco.
class CategoriasBiblioteca {
  static const livros = 'Livros';
  static const eletronicos = 'Eletrônicos';
  static const itensGerais = 'Itens Gerais';
  static const salas = 'Salas';
  static const todas = [livros, eletronicos, itensGerais, salas];

  static bool valida(String valor) => todas.contains(valor);
}

class PapeisUsuario {
  static const aluno = 'aluno';
  static const admin = 'admin';
}

class Usuario {
  final String id;
  final String cpf;
  final String email;
  final String papel;
  final String? nome;

  const Usuario({
    required this.id,
    required this.cpf,
    required this.email,
    this.papel = PapeisUsuario.aluno,
    this.nome,
  });

  bool get ehAdmin => papel == PapeisUsuario.admin;

  Map<String, Object?> toJson() => {
        'id': id,
        'cpf': cpf,
        'email': email,
        'nome': nome,
        'papel': papel,
      };
}

/// Registro restrito ao backend. Hash e salt não são enviados para o app.
class RegistroUsuario {
  final Usuario usuario;
  final List<int> salt;
  final List<int> hashSenha;

  const RegistroUsuario({
    required this.usuario,
    required this.salt,
    required this.hashSenha,
  });
}

class Sessao {
  final String usuarioId;
  final DateTime expiraEm;
  const Sessao({required this.usuarioId, required this.expiraEm});
}

class ItemAcervo {
  final String id;
  final String nome;
  final String descricao;
  final String origem; // 'biblioteca' ou 'alunos'
  final String? categoria; // Apenas itens da biblioteca
  final bool disponivel;
  final String? donoId; // Apenas itens do acervo dos alunos
  final String? contato; // Contato público fornecido pelo anunciante no acervo dos alunos
  final Map<String, Object?> detalhes; // Campos específicos: autor, ISBN etc.
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const ItemAcervo({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.origem,
    required this.disponivel,
    required this.criadoEm,
    required this.atualizadoEm,
    this.categoria,
    this.donoId,
    this.contato,
    this.detalhes = const {},
  });

  ItemAcervo copiarCom({
    String? nome,
    String? descricao,
    String? categoria,
    bool? disponivel,
    String? contato,
    Map<String, Object?>? detalhes,
    DateTime? atualizadoEm,
  }) =>
      ItemAcervo(
        id: id,
        nome: nome ?? this.nome,
        descricao: descricao ?? this.descricao,
        origem: origem,
        categoria: categoria ?? this.categoria,
        disponivel: disponivel ?? this.disponivel,
        donoId: donoId,
        contato: contato ?? this.contato,
        detalhes: detalhes ?? this.detalhes,
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm ?? DateTime.now().toUtc(),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'origem': origem,
        'categoria': categoria,
        'disponivel': disponivel,
        'donoId': donoId,
        'contato': contato,
        'detalhes': detalhes,
        'criadoEm': criadoEm.toUtc().toIso8601String(),
        'atualizadoEm': atualizadoEm.toUtc().toIso8601String(),
      };
}

/// Consulta reaproveitada por biblioteca, categorias e acervo.
class FiltroItens {
  final String? busca;
  final String? categoria;
  final bool? disponivel;
  final String? donoId;
  final int pagina;
  final int limite;

  const FiltroItens({
    this.busca,
    this.categoria,
    this.disponivel,
    this.donoId,
    this.pagina = 1,
    this.limite = 20,
  });

  void validar() {
    if (pagina < 1 || limite < 1 || limite > 100) {
      throw const ErroApi(400, 'pagina >= 1 e limite entre 1 e 100.', 'paginacao_invalida');
    }
    if ((busca ?? '').length > 150) {
      throw const ErroApi(400, 'A pesquisa deve ter até 150 caracteres.');
    }
  }
}

class PaginaItens {
  final List<ItemAcervo> itens;
  final int total;
  final int pagina;
  final int limite;

  const PaginaItens({
    required this.itens,
    required this.total,
    required this.pagina,
    required this.limite,
  });

  Map<String, Object?> toJson() => {
        'total': total,
        'pagina': pagina,
        'limite': limite,
        'totalPaginas': (total / limite).ceil(),
        'itens': itens.map((item) => item.toJson()).toList(),
      };
}
