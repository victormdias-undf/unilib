import 'modelos.dart';
import 'emprestimo_modelos.dart';

/// A equipe de banco de dados deve implementar estas interfaces.
/// Não alterar a API ao trocar memória por banco.
abstract class RepositorioUsuarios {
  Future<RegistroUsuario?> buscarPorCpf(String cpfNormalizado);
  Future<RegistroUsuario?> buscarPorEmail(String emailNormalizado);
  Future<RegistroUsuario?> buscarPorId(String id);

  /// Retorna false se CPF OU e-mail já existem. Fazer de forma atômica no banco.
  Future<bool> inserirSeNovo(RegistroUsuario registro);
}

abstract class RepositorioSessoes {
  Future<void> salvar(String token, Sessao sessao);
  Future<Sessao?> buscar(String token);
  Future<void> remover(String token);
}

abstract class RepositorioItens {
  /// O banco pode aplicar os filtros na consulta; a paginação é realizada no serviço.
  /// Uma futura implementação SQL pode otimizar usando COUNT/LIMIT/OFFSET.
  Future<List<ItemAcervo>> listar({
    required String origem,
    String? busca,
    String? categoria,
    bool? disponivel,
    String? donoId,
  });
  Future<ItemAcervo?> buscar(String origem, String id);
  Future<ItemAcervo> inserir(ItemAcervo item);
  Future<ItemAcervo?> salvar(ItemAcervo item);
  Future<bool> remover(String origem, String id);
}

/// Contrato para favoritos de livros por usuário.
/// O banco deve impor UNIQUE(usuarioId, livroId) e referências aos usuários/itens.
abstract class RepositorioFavoritosLivros {
  /// True se adicionou; false se o livro já estava favoritado.
  Future<bool> adicionarLivro({required String usuarioId, required String livroId});

  /// True se removeu; false se não estava na lista.
  Future<bool> removerLivro({required String usuarioId, required String livroId});

  Future<bool> contemLivro({required String usuarioId, required String livroId});

  /// Retorna apenas os IDs de livros favoritados pelo usuário informado.
  Future<List<String>> listarIdsLivros({required String usuarioId});
}

/// Persistência dos empréstimos de livros (implementação SQL fica com o banco).
/// Operações condicionais precisam ser atômicas para não permitir dois
/// empréstimos ativos do mesmo livro nem devoluções/renovações simultâneas.
abstract class RepositorioEmprestimos {
  /// Retorna false se já há empréstimo ativo para o mesmo livro.
  Future<bool> inserirSeLivre(EmprestimoLivro emprestimo);
  Future<EmprestimoLivro?> buscarPorId(String id);
  Future<EmprestimoLivro?> ativoDoLivro(String livroId);
  Future<List<EmprestimoLivro>> listar({String? usuarioId});

  /// Retorna null se não existe ou já foi devolvido.
  Future<EmprestimoLivro?> marcarDevolvido(String id, DateTime devolvidoEm);

  /// Atualiza apenas se ainda está ativo e o número de renovações é o esperado.
  Future<EmprestimoLivro?> renovar(
    String id, {
    required DateTime novoPrazo,
    required int renovacoesEsperadas,
  });

  /// Desfaz somente uma inserção recém-criada em caso de falha ao atualizar o item.
  Future<void> cancelarInsercao(String id);
}
