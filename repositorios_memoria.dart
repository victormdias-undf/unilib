import 'contratos.dart';
import 'modelos.dart';
import 'emprestimo_modelos.dart';

/// Implementações de desenvolvimento. Todos os dados são perdidos ao reiniciar.
class UsuariosEmMemoria implements RepositorioUsuarios {
  final Map<String, RegistroUsuario> _porCpf = {};
  final Map<String, RegistroUsuario> _porEmail = {};
  final Map<String, RegistroUsuario> _porId = {};

  @override
  Future<RegistroUsuario?> buscarPorCpf(String cpfNormalizado) async => _porCpf[cpfNormalizado];
  @override
  Future<RegistroUsuario?> buscarPorEmail(String emailNormalizado) async => _porEmail[emailNormalizado];
  @override
  Future<RegistroUsuario?> buscarPorId(String id) async => _porId[id];

  @override
  Future<bool> inserirSeNovo(RegistroUsuario registro) async {
    final usuario = registro.usuario;
    if (_porCpf.containsKey(usuario.cpf) || _porEmail.containsKey(usuario.email)) {
      return false;
    }
    // Sem 'await' entre checagem e inserção: operação atômica neste isolate.
    _porCpf[usuario.cpf] = registro;
    _porEmail[usuario.email] = registro;
    _porId[usuario.id] = registro;
    return true;
  }
}

class SessoesEmMemoria implements RepositorioSessoes {
  final Map<String, Sessao> _sessoes = {};
  @override
  Future<void> salvar(String token, Sessao sessao) async { _sessoes[token] = sessao; }
  @override
  Future<Sessao?> buscar(String token) async => _sessoes[token];
  @override
  Future<void> remover(String token) async { _sessoes.remove(token); }
}

class ItensEmMemoria implements RepositorioItens {
  final Map<String, ItemAcervo> _itens = {};

  ItensEmMemoria();

  /// Amostras demonstrativas, nunca dados reais da universidade.
  factory ItensEmMemoria.comExemplos() {
    final repositorio = ItensEmMemoria();
    final quantidades = <String, int>{
      CategoriasBiblioteca.livros: 12,
      CategoriasBiblioteca.eletronicos: 6,
      CategoriasBiblioteca.itensGerais: 9,
      CategoriasBiblioteca.salas: 4,
    };
    var contador = 1;
    final agora = DateTime.now().toUtc();
    for (final categoria in quantidades.keys) {
      for (var numero = 1; numero <= quantidades[categoria]!; numero++) {
        final id = 'bib-$contador';
        repositorio._itens[id] = ItemAcervo(
          id: id,
          nome: '${categoria == 'Livros' ? 'Livro' : categoria == 'Salas' ? 'Sala' : categoria == 'Eletrônicos' ? 'Eletrônico' : 'Item geral'} $numero',
          descricao: 'Exemplo de $categoria',
          origem: 'biblioteca',
          categoria: categoria,
          disponivel: true,
          criadoEm: agora,
          atualizadoEm: agora,
        );
        contador++;
      }
    }
    return repositorio;
  }

  @override
  Future<List<ItemAcervo>> listar({
    required String origem,
    String? busca,
    String? categoria,
    bool? disponivel,
    String? donoId,
  }) async {
    final pesquisa = (busca ?? '').trim().toLowerCase();
    final resultado = _itens.values.where((item) {
      if (item.origem != origem) return false;
      if (categoria != null && item.categoria != categoria) return false;
      if (disponivel != null && item.disponivel != disponivel) return false;
      if (donoId != null && item.donoId != donoId) return false;
      if (pesquisa.isNotEmpty &&
          !'${item.nome} ${item.descricao}'.toLowerCase().contains(pesquisa)) {
        return false;
      }
      return true;
    }).toList();
    resultado.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return resultado;
  }

  @override
  Future<ItemAcervo?> buscar(String origem, String id) async {
    final item = _itens[id];
    return item?.origem == origem ? item : null;
  }

  @override
  Future<ItemAcervo> inserir(ItemAcervo item) async {
    if (_itens.containsKey(item.id)) {
      throw const ErroApi(409, 'ID de item duplicado.', 'item_duplicado');
    }
    _itens[item.id] = item;
    return item;
  }

  @override
  Future<ItemAcervo?> salvar(ItemAcervo item) async {
    if (await buscar(item.origem, item.id) == null) return null;
    _itens[item.id] = item;
    return item;
  }

  @override
  Future<bool> remover(String origem, String id) async {
    if (await buscar(origem, id) == null) return false;
    _itens.remove(id);
    return true;
  }
}

/// Favoritos de desenvolvimento: isolados por usuário; perdidos ao reiniciar.
class FavoritosLivrosEmMemoria implements RepositorioFavoritosLivros {
  final Map<String, Set<String>> _porUsuario = {};

  @override
  Future<bool> adicionarLivro({required String usuarioId, required String livroId}) async {
    return _porUsuario.putIfAbsent(usuarioId, () => <String>{}).add(livroId);
  }

  @override
  Future<bool> removerLivro({required String usuarioId, required String livroId}) async {
    return _porUsuario[usuarioId]?.remove(livroId) ?? false;
  }

  @override
  Future<bool> contemLivro({required String usuarioId, required String livroId}) async {
    return _porUsuario[usuarioId]?.contains(livroId) ?? false;
  }

  @override
  Future<List<String>> listarIdsLivros({required String usuarioId}) async {
    return List<String>.of(_porUsuario[usuarioId] ?? <String>{});
  }
}

/// Repositório de empréstimos para desenvolvimento (sem persistência).
/// Condições de exclusividade são verificadas antes de qualquer await.
class EmprestimosEmMemoria implements RepositorioEmprestimos {
  final Map<String, EmprestimoLivro> _porId = {};

  @override
  Future<bool> inserirSeLivre(EmprestimoLivro emprestimo) async {
    if (_porId.containsKey(emprestimo.id) ||
        _porId.values.any((e) => e.livroId == emprestimo.livroId && e.ativo)) {
      return false;
    }
    _porId[emprestimo.id] = emprestimo;
    return true;
  }

  @override
  Future<EmprestimoLivro?> buscarPorId(String id) async => _porId[id];

  @override
  Future<EmprestimoLivro?> ativoDoLivro(String livroId) async {
    for (final emprestimo in _porId.values) {
      if (emprestimo.livroId == livroId && emprestimo.ativo) return emprestimo;
    }
    return null;
  }

  @override
  Future<List<EmprestimoLivro>> listar({String? usuarioId}) async {
    final lista = _porId.values
        .where((e) => usuarioId == null || e.usuarioId == usuarioId)
        .toList();
    lista.sort((a, b) => b.retiradoEm.compareTo(a.retiradoEm));
    return lista;
  }

  @override
  Future<EmprestimoLivro?> marcarDevolvido(String id, DateTime devolvidoEm) async {
    final atual = _porId[id];
    if (atual == null || !atual.ativo) return null;
    final atualizado = atual.copiarCom(devolvidoEm: devolvidoEm);
    _porId[id] = atualizado;
    return atualizado;
  }

  @override
  Future<EmprestimoLivro?> renovar(
    String id, {
    required DateTime novoPrazo,
    required int renovacoesEsperadas,
  }) async {
    final atual = _porId[id];
    if (atual == null || !atual.ativo || atual.renovacoes != renovacoesEsperadas) {
      return null;
    }
    final atualizado = atual.copiarCom(
      prazoDevolucao: novoPrazo,
      renovacoes: atual.renovacoes + 1,
    );
    _porId[id] = atualizado;
    return atualizado;
  }

  @override
  Future<void> cancelarInsercao(String id) async {
    _porId.remove(id);
  }
}
