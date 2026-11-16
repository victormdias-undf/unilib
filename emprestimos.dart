import '../contratos.dart';
import '../emprestimo_modelos.dart';
import '../identificadores.dart';
import '../listagens.dart';
import '../modelos.dart';
import 'biblioteca.dart';

/// Regras para empréstimos de exemplares da Biblioteca Geral, categoria Livros.
/// Não trata de multas (dependem de política institucional).
class ServicoEmprestimos {
  final RepositorioEmprestimos emprestimos;
  final ServicoBiblioteca biblioteca;
  final PoliticaEmprestimos politica;
  final DateTime Function() agora;

  ServicoEmprestimos({
    required this.emprestimos,
    required this.biblioteca,
    this.politica = const PoliticaEmprestimos(),
    DateTime Function()? agora,
  }) : agora = agora ?? DateTime.now {
    politica.validar();
  }

  DateTime _agora() => agora().toUtc();

  Future<EmprestimoLivro> emprestarLivro({
    required Usuario administrador,
    required Usuario aluno,
    required String livroId,
  }) async {
    exigirAdministrador(administrador);
    if (aluno.papel != PapeisUsuario.aluno) {
      throw const ErroApi(400, 'O destinatário deve ser um aluno cadastrado.', 'aluno_invalido');
    }
    // A regra vale para qualquer livro novo, não apenas para o já atrasado.
    await verificarPendenciasAluno(aluno: aluno);
    final livro = await biblioteca.detalhar(livroId);
    if (livro.categoria != CategoriasBiblioteca.livros) {
      throw const ErroApi(400, 'Somente livros da Biblioteca Geral podem ser emprestados.', 'nao_e_livro');
    }
    if (!livro.disponivel) {
      throw const ErroApi(409, 'Este livro está indisponível para empréstimo.', 'livro_indisponivel');
    }
    final retirada = _agora();
    final registro = EmprestimoLivro(
      id: gerarIdentificador(),
      livroId: livroId,
      usuarioId: aluno.id,
      retiradoEm: retirada,
      prazoDevolucao: retirada.add(Duration(days: politica.diasPrazo)),
    );
    if (!await emprestimos.inserirSeLivre(registro)) {
      throw const ErroApi(409, 'Este exemplar já está emprestado.', 'emprestimo_ativo');
    }
    try {
      final atualizado = await biblioteca.itens.salvar(livro.copiarCom(disponivel: false));
      if (atualizado == null) {
        throw const ErroApi(409, 'O livro foi removido durante o empréstimo.');
      }
    } catch (_) {
      await emprestimos.cancelarInsercao(registro.id);
      rethrow;
    }
    return registro;
  }

  /// Impede novas retiradas enquanto o aluno possuir pelo menos um livro
  /// vencido e ainda não devolvido. Um atraso já devolvido não bloqueia.
  /// Não precisa de agendamento: a situação é calculada em tempo real.
  Future<void> verificarPendenciasAluno({required Usuario aluno}) async {
    final referencia = _agora();
    final historico = await emprestimos.listar(usuarioId: aluno.id);
    final possuiAtrasoAtivo = historico.any(
      (e) => e.ativo &&
          e.situacaoEm(referencia) == SituacoesEmprestimo.atrasado,
    );
    if (possuiAtrasoAtivo) {
      throw const ErroApi(
        409,
        'Empréstimo bloqueado: o aluno possui livro com devolução em atraso. '
        'Regularize a pendência antes de retirar outro livro.',
        'aluno_com_emprestimo_atrasado',
      );
    }
  }

  Future<EmprestimoLivro> detalhar({required Usuario usuario, required String id}) async {
    final emprestimo = await emprestimos.buscarPorId(id);
    if (emprestimo == null) {
      throw const ErroApi(404, 'Empréstimo não encontrado.', 'emprestimo_nao_encontrado');
    }
    if (!usuario.ehAdmin && emprestimo.usuarioId != usuario.id) {
      throw const ErroApi(403, 'Você não pode consultar este empréstimo.', 'permissao_negada');
    }
    return emprestimo;
  }

  /// Somente administradores podem confirmar a devolução física do livro.
  Future<EmprestimoLivro> registrarDevolucao({
    required Usuario usuario,
    required String id,
  }) async {
    exigirAdministrador(usuario);
    final atual = await detalhar(usuario: usuario, id: id);
    if (!atual.ativo) {
      throw const ErroApi(409, 'Este empréstimo já foi devolvido.', 'ja_devolvido');
    }
    final devolucao = await emprestimos.marcarDevolvido(id, _agora());
    if (devolucao == null) {
      throw const ErroApi(409, 'Este empréstimo já foi devolvido.', 'ja_devolvido');
    }
    final item = await biblioteca.itens.buscar('biblioteca', devolucao.livroId);
    if (item != null) {
      await biblioteca.itens.salvar(item.copiarCom(disponivel: true));
    }
    return devolucao;
  }

  /// Apenas admin pode renovar, antes do vencimento e dentro do limite da política.
  Future<EmprestimoLivro> renovarPrazo({
    required Usuario administrador,
    required String id,
  }) async {
    exigirAdministrador(administrador);
    final atual = await detalhar(usuario: administrador, id: id);
    if (!atual.ativo) {
      throw const ErroApi(409, 'Não é possível renovar um empréstimo devolvido.', 'ja_devolvido');
    }
    if (_agora().isAfter(atual.prazoDevolucao)) {
      throw const ErroApi(409, 'Não é possível renovar um empréstimo atrasado.', 'emprestimo_atrasado');
    }
    if (atual.renovacoes >= politica.maxRenovacoes) {
      throw const ErroApi(409, 'Limite de renovações atingido.', 'limite_renovacoes');
    }
    final atualizado = await emprestimos.renovar(
      id,
      novoPrazo: atual.prazoDevolucao.add(Duration(days: politica.diasRenovacao)),
      renovacoesEsperadas: atual.renovacoes,
    );
    if (atualizado == null) {
      throw const ErroApi(409, 'Empréstimo alterado por outra operação.', 'conflito_emprestimo');
    }
    return atualizado;
  }

  Future<PaginaEmprestimos> meusEmprestimos({
    required Usuario usuario,
    int pagina = 1,
    int limite = 20,
  }) => _listar(usuarioId: usuario.id, pagina: pagina, limite: limite);

  Future<PaginaEmprestimos> listarTodos({
    required Usuario administrador,
    int pagina = 1,
    int limite = 20,
  }) async {
    exigirAdministrador(administrador);
    return _listar(pagina: pagina, limite: limite);
  }

  Future<PaginaEmprestimos> listarAtrasados({
    required Usuario administrador,
    int pagina = 1,
    int limite = 20,
  }) async {
    exigirAdministrador(administrador);
    return _listar(apenasAtrasados: true, pagina: pagina, limite: limite);
  }

  Future<PaginaEmprestimos> _listar({
    String? usuarioId,
    bool apenasAtrasados = false,
    required int pagina,
    required int limite,
  }) async {
    FiltroItens(pagina: pagina, limite: limite).validar();
    final referencia = _agora();
    final todos = await emprestimos.listar(usuarioId: usuarioId);
    final filtrados = apenasAtrasados
        ? todos.where((e) => e.situacaoEm(referencia) == SituacoesEmprestimo.atrasado).toList()
        : todos;
    final inicio = (pagina - 1) * limite;
    return PaginaEmprestimos(
      emprestimos: inicio >= filtrados.length
          ? const [] : filtrados.skip(inicio).take(limite).toList(),
      total: filtrados.length,
      pagina: pagina,
      limite: limite,
      referencia: referencia,
    );
  }
}
