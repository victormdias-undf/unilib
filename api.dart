import 'dart:convert';
import 'dart:io';

import 'listagens.dart';
import 'modelos.dart';
import 'validacoes.dart';
import 'servicos/emprestimos.dart';
import 'servicos/autenticacao.dart';
import 'servicos/acervo_alunos.dart';
import 'servicos/biblioteca.dart';
import 'servicos/favoritos_livros.dart';

/// API REST: auth, biblioteca, acervo-alunos, favoritos e empréstimos.
class ApiUniLib {
  final ServicoAutenticacao autenticacao;
  final ServicoBiblioteca biblioteca;
  final ServicoAcervoAlunos acervo;
  final ServicoFavoritosLivros favoritos;
  final ServicoEmprestimos emprestimos;
  final Set<String> origensAdicionais;

  const ApiUniLib({
    required this.autenticacao,
    required this.biblioteca,
    required this.acervo,
    required this.favoritos,
    required this.emprestimos,
    this.origensAdicionais = const {},
  });

  Future<void> atender(HttpRequest req) async {
    final res = req.response;
    _configurarCors(req);
    if (req.method == 'OPTIONS') {
      res.statusCode = 204;
      await res.close();
      return;
    }
    try {
      final partes = req.uri.pathSegments.where((p) => p.isNotEmpty).toList();
      if (partes.isEmpty || partes.first != 'api') {
        throw const ErroApi(404, 'Rota não encontrada.', 'rota_inexistente');
      }
      if (_rota(partes, ['api', 'health']) && req.method == 'GET') {
        await _json(res, 200, {'status': 'ok', 'projeto': 'UniLib', 'versao': '1.3.0'});
        return;
      }
      if (partes.length >= 2 && partes[1] == 'auth') {
        await _rotasAuth(req, partes);
        return;
      }
      if (partes.length >= 2 && partes[1] == 'biblioteca') {
        await _rotasBiblioteca(req, partes);
        return;
      }
      if (partes.length >= 2 && partes[1] == 'favoritos') {
        await _rotasFavoritos(req, partes);
        return;
      }
      if (partes.length >= 2 && partes[1] == 'emprestimos') {
        await _rotasEmprestimos(req, partes);
        return;
      }
      if (partes.length >= 2 && partes[1] == 'acervo-alunos') {
        await _rotasAcervo(req, partes);
        return;
      }
      throw const ErroApi(404, 'Rota não encontrada.', 'rota_inexistente');
    } on ErroApi catch (e) {
      await _json(res, e.status, {'erro': e.mensagem, 'codigo': e.codigo});
    } on FormatException {
      await _json(res, 400, {'erro': 'JSON inválido.', 'codigo': 'json_invalido'});
    } catch (e, pilha) {
      stderr.writeln('Erro interno UniLib: $e\n$pilha');
      try {
        await _json(res, 500, {'erro': 'Erro interno do servidor.', 'codigo': 'erro_interno'});
      } catch (_) {
        // Uma conexão encerrada pelo cliente não deve encerrar o servidor.
      }
    }
  }

  Future<void> _rotasAuth(HttpRequest req, List<String> p) async {
    if (p.length != 3) throw const ErroApi(404, 'Rota não encontrada.');
    final acao = p[2];
    if (acao == 'cadastro' && req.method == 'POST') {
      final corpo = await _lerJson(req);
      final usuario = await autenticacao.cadastrar(
        cpf: _obrigatorio(corpo, 'cpf'),
        email: _obrigatorio(corpo, 'email'),
        senha: _obrigatorio(corpo, 'senha'),
        nome: _opcional(corpo, 'nome'),
      );
      await _json(req.response, 201, {'usuario': usuario.toJson()});
      return;
    }
    if (acao == 'login' && req.method == 'POST') {
      final corpo = await _lerJson(req);
      final resultado = await autenticacao.entrar(
        cpf: _obrigatorio(corpo, 'cpf'),
        senha: _obrigatorio(corpo, 'senha'),
      );
      await _json(req.response, 200, resultado.toJson());
      return;
    }
    if (acao == 'me' && req.method == 'GET') {
      final usuario = await _usuario(req);
      await _json(req.response, 200, {'usuario': usuario.toJson()});
      return;
    }
    if (acao == 'logout' && req.method == 'POST') {
      final token = _token(req);
      await autenticacao.sair(token ?? '');
      await _json(req.response, 200, {'mensagem': 'Sessão encerrada.'});
      return;
    }
    throw const ErroApi(404, 'Rota não encontrada.');
  }

  Future<void> _rotasBiblioteca(HttpRequest req, List<String> p) async {
    if (p.length == 3 && p[2] == 'categorias' && req.method == 'GET') {
      await _json(req.response, 200, {'categorias': CategoriasBiblioteca.todas});
      return;
    }
    if (p.length == 3 && p[2] == 'resumo' && req.method == 'GET') {
      final categorias = <Map<String, Object?>>[];
      for (final c in CategoriasBiblioteca.todas) {
        final tudo = await biblioteca.listarBiblioteca(FiltroItens(categoria: c, limite: 1));
        final disponiveis = await biblioteca.listarBiblioteca(
          FiltroItens(categoria: c, disponivel: true, limite: 1),
        );
        categorias.add({
          'categoria': c,
          'total': tudo.total,
          'disponiveis': disponiveis.total,
        });
      }
      await _json(req.response, 200, {'categorias': categorias});
      return;
    }
    if (p.length == 2 && req.method == 'GET') {
      final resultado = await biblioteca.listarBiblioteca(_filtro(req, comCategoria: true));
      await _json(req.response, 200, resultado.toJson());
      return;
    }
    final categoriasPorSlug = <String, String>{
      'livros': CategoriasBiblioteca.livros,
      'eletronicos': CategoriasBiblioteca.eletronicos,
      'itens-gerais': CategoriasBiblioteca.itensGerais,
      'salas': CategoriasBiblioteca.salas,
    };
    if (p.length == 3 && categoriasPorSlug.containsKey(p[2])) {
      final categoria = categoriasPorSlug[p[2]]!;
      if (req.method == 'GET') {
        final filtro = _filtro(req);
        final resultado = await biblioteca.listarBiblioteca(FiltroItens(
          busca: filtro.busca,
          categoria: categoria,
          disponivel: filtro.disponivel,
          pagina: filtro.pagina,
          limite: filtro.limite,
        ));
        await _json(req.response, 200, resultado.toJson());
        return;
      }
      if (req.method == 'POST') {
        final usuario = await _usuario(req);
        final corpo = await _lerJson(req);
        final item = await biblioteca.cadastrarItem(
          administrador: usuario,
          categoria: categoria,
          nome: _obrigatorio(corpo, 'nome'),
          descricao: _opcional(corpo, 'descricao') ?? '',
          disponivel: _booleano(corpo, 'disponivel', padrao: true),
          detalhes: _detalhes(corpo),
        );
        await _json(req.response, 201, {'item': item.toJson()});
        return;
      }
    }
    if (p.length == 2 && req.method == 'POST') {
      final usuario = await _usuario(req);
      final corpo = await _lerJson(req);
      final item = await biblioteca.cadastrarItem(
        administrador: usuario,
        categoria: _obrigatorio(corpo, 'categoria'),
        nome: _obrigatorio(corpo, 'nome'),
        descricao: _opcional(corpo, 'descricao') ?? '',
        disponivel: _booleano(corpo, 'disponivel', padrao: true),
        detalhes: _detalhes(corpo),
      );
      await _json(req.response, 201, {'item': item.toJson()});
      return;
    }
    if (p.length == 3 && req.method == 'GET') {
      final item = await biblioteca.detalhar(p[2]);
      await _json(req.response, 200, {'item': item.toJson()});
      return;
    }
    if (p.length == 3 && (req.method == 'PUT' || req.method == 'PATCH')) {
      final usuario = await _usuario(req);
      final corpo = await _lerJson(req);
      final item = await biblioteca.atualizarItem(
        administrador: usuario,
        id: p[2],
        nome: _opcional(corpo, 'nome'),
        descricao: _opcional(corpo, 'descricao'),
        categoria: _opcional(corpo, 'categoria'),
        disponivel: corpo.containsKey('disponivel')
            ? _booleano(corpo, 'disponivel', padrao: false) : null,
        detalhes: corpo.containsKey('detalhes') ? _detalhes(corpo) : null,
      );
      await _json(req.response, 200, {'item': item.toJson()});
      return;
    }
    if (p.length == 4 && p[3] == 'disponibilidade' && req.method == 'PATCH') {
      final usuario = await _usuario(req);
      final corpo = await _lerJson(req);
      if (!corpo.containsKey('disponivel')) {
        throw const ErroApi(400, 'Campo obrigatório: disponivel.');
      }
      final item = await biblioteca.definirDisponibilidade(
        administrador: usuario,
        id: p[2],
        disponivel: _booleano(corpo, 'disponivel', padrao: false),
      );
      await _json(req.response, 200, {'item': item.toJson()});
      return;
    }
    if (p.length == 3 && req.method == 'DELETE') {
      final usuario = await _usuario(req);
      await biblioteca.excluirItem(administrador: usuario, id: p[2]);
      await _vazio(req.response);
      return;
    }
    throw const ErroApi(404, 'Rota não encontrada.');
  }

  Future<void> _rotasAcervo(HttpRequest req, List<String> p) async {
    if (p.length == 2 && req.method == 'GET') {
      final resultado = await acervo.listarAcervo(_filtro(req, comDono: true));
      await _json(req.response, 200, resultado.toJson());
      return;
    }
    if (p.length == 3 && p[2] == 'meus' && req.method == 'GET') {
      final usuario = await _usuario(req);
      final resultado = await acervo.listarMeusItens(usuario, _filtro(req));
      await _json(req.response, 200, resultado.toJson());
      return;
    }
    if (p.length == 2 && req.method == 'POST') {
      final usuario = await _usuario(req);
      final corpo = await _lerJson(req);
      final item = await acervo.cadastrarItem(
        usuario: usuario,
        nome: _obrigatorio(corpo, 'nome'),
        descricao: _obrigatorio(corpo, 'descricao'),
        contato: _obrigatorio(corpo, 'contato'),
        disponivel: _booleano(corpo, 'disponivel', padrao: true),
        detalhes: _detalhes(corpo),
      );
      await _json(req.response, 201, {'item': item.toJson()});
      return;
    }
    if (p.length == 3 && req.method == 'GET') {
      final item = await acervo.detalhar(p[2]);
      await _json(req.response, 200, {'item': item.toJson()});
      return;
    }
    if (p.length == 3 && (req.method == 'PUT' || req.method == 'PATCH')) {
      final usuario = await _usuario(req);
      final corpo = await _lerJson(req);
      final item = await acervo.atualizarItem(
        usuario: usuario,
        id: p[2],
        nome: _opcional(corpo, 'nome'),
        descricao: _opcional(corpo, 'descricao'),
        contato: _opcional(corpo, 'contato'),
        disponivel: corpo.containsKey('disponivel')
            ? _booleano(corpo, 'disponivel', padrao: false) : null,
        detalhes: corpo.containsKey('detalhes') ? _detalhes(corpo) : null,
      );
      await _json(req.response, 200, {'item': item.toJson()});
      return;
    }
    if (p.length == 4 && p[3] == 'disponibilidade' && req.method == 'PATCH') {
      final usuario = await _usuario(req);
      final corpo = await _lerJson(req);
      if (!corpo.containsKey('disponivel')) {
        throw const ErroApi(400, 'Campo obrigatório: disponivel.');
      }
      final item = await acervo.definirDisponibilidade(
        usuario: usuario,
        id: p[2],
        disponivel: _booleano(corpo, 'disponivel', padrao: false),
      );
      await _json(req.response, 200, {'item': item.toJson()});
      return;
    }
    if (p.length == 3 && req.method == 'DELETE') {
      final usuario = await _usuario(req);
      await acervo.excluirItem(usuario: usuario, id: p[2]);
      await _vazio(req.response);
      return;
    }
    throw const ErroApi(404, 'Rota não encontrada.');
  }

  /// Favoritos pessoais do usuário autenticado. Não aceita usuarioId no corpo.
  Future<void> _rotasFavoritos(HttpRequest req, List<String> p) async {
    if (p.length < 3 || p[2] != 'livros') {
      throw const ErroApi(404, 'Rota não encontrada.');
    }
    final usuario = await _usuario(req);
    if (p.length == 3 && req.method == 'GET') {
      final resultado = await favoritos.listarFavoritos(
        usuario: usuario,
        filtro: _filtro(req),
      );
      await _json(req.response, 200, resultado.toJson());
      return;
    }
    if (p.length == 4 && req.method == 'POST') {
      final adicionado = await favoritos.favoritarLivro(usuario: usuario, livroId: p[3]);
      await _json(req.response, adicionado ? 201 : 200, {
        'livroId': p[3],
        'favorito': true,
        'adicionado': adicionado,
      });
      return;
    }
    if (p.length == 4 && req.method == 'GET') {
      final favorito = await favoritos.verificarFavorito(usuario: usuario, livroId: p[3]);
      await _json(req.response, 200, {'livroId': p[3], 'favorito': favorito});
      return;
    }
    if (p.length == 4 && req.method == 'DELETE') {
      await favoritos.desfavoritarLivro(usuario: usuario, livroId: p[3]);
      await _vazio(req.response);
      return;
    }
    throw const ErroApi(404, 'Rota não encontrada.');
  }

  /// Só o administrador registra retiradas e devoluções. O aluno é
  /// identificado por CPF no corpo da retirada e verificado no repositório.
  Future<void> _rotasEmprestimos(HttpRequest req, List<String> p) async {
    final usuario = await _usuario(req);
    final (pagina, limite) = _paginaLimite(req);

    if (p.length == 2 && req.method == 'POST') {
      exigirAdministrador(usuario);
      final corpo = await _lerJson(req);
      final cpf = Validacoes.somenteNumeros(_obrigatorio(corpo, 'cpfAluno'));
      if (!Validacoes.cpfValido(cpf)) {
        throw const ErroApi(400, 'CPF do aluno inválido.', 'cpf_invalido');
      }
      final registroAluno = await autenticacao.usuarios.buscarPorCpf(cpf);
      if (registroAluno == null) {
        throw const ErroApi(404, 'Aluno não encontrado.', 'aluno_nao_encontrado');
      }
      final registro = await emprestimos.emprestarLivro(
        administrador: usuario,
        aluno: registroAluno.usuario,
        livroId: _obrigatorio(corpo, 'livroId'),
      );
      await _json(req.response, 201, {'emprestimo': registro.toJson()});
      return;
    }
    if (p.length == 2 && req.method == 'GET') {
      final lista = await emprestimos.listarTodos(
        administrador: usuario, pagina: pagina, limite: limite);
      await _json(req.response, 200, lista.toJson());
      return;
    }
    if (p.length == 3 && p[2] == 'meus' && req.method == 'GET') {
      final lista = await emprestimos.meusEmprestimos(
        usuario: usuario, pagina: pagina, limite: limite);
      await _json(req.response, 200, lista.toJson());
      return;
    }
    if (p.length == 3 && p[2] == 'atrasados' && req.method == 'GET') {
      final lista = await emprestimos.listarAtrasados(
        administrador: usuario, pagina: pagina, limite: limite);
      await _json(req.response, 200, lista.toJson());
      return;
    }
    if (p.length == 3 && req.method == 'GET') {
      final registro = await emprestimos.detalhar(usuario: usuario, id: p[2]);
      await _json(req.response, 200, {'emprestimo': registro.toJson()});
      return;
    }
    if (p.length == 4 && p[3] == 'devolucao' && req.method == 'POST') {
      final registro = await emprestimos.registrarDevolucao(usuario: usuario, id: p[2]);
      await _json(req.response, 200, {'emprestimo': registro.toJson()});
      return;
    }
    if (p.length == 4 && p[3] == 'renovacao' && req.method == 'POST') {
      final registro = await emprestimos.renovarPrazo(administrador: usuario, id: p[2]);
      await _json(req.response, 200, {'emprestimo': registro.toJson()});
      return;
    }
    throw const ErroApi(404, 'Rota não encontrada.');
  }

  (int, int) _paginaLimite(HttpRequest req) {
    final q = req.uri.queryParameters;
    final pagina = q.containsKey('pagina') ? int.tryParse(q['pagina']!) : 1;
    final limite = q.containsKey('limite') ? int.tryParse(q['limite']!) : 20;
    if (pagina == null || limite == null || pagina < 1 || limite < 1 || limite > 100) {
      throw const ErroApi(400, 'pagina >= 1 e limite entre 1 e 100.', 'paginacao_invalida');
    }
    return (pagina, limite);
  }

  bool _rota(List<String> p, List<String> esperado) =>
      p.length == esperado.length &&
      List.generate(p.length, (i) => p[i] == esperado[i]).every((v) => v);

  String? _token(HttpRequest req) {
    final header = req.headers.value(HttpHeaders.authorizationHeader);
    if (header == null) return null;
    final correspondencia = RegExp(r'^Bearer\s+(\S+)$', caseSensitive: false).firstMatch(header);
    return correspondencia?.group(1);
  }

  Future<Usuario> _usuario(HttpRequest req) => autenticacao.usuarioPeloToken(_token(req));

  FiltroItens _filtro(HttpRequest req, {bool comCategoria = false, bool comDono = false}) {
    final q = req.uri.queryParameters;
    final pagina = q.containsKey('pagina') ? int.tryParse(q['pagina']!) : 1;
    final limite = q.containsKey('limite') ? int.tryParse(q['limite']!) : 20;
    if (pagina == null || limite == null) {
      throw const ErroApi(400, 'pagina e limite devem ser números inteiros.');
    }
    bool? disponivel;
    if (q.containsKey('disponivel')) {
      if (q['disponivel'] == 'true') {
        disponivel = true;
      } else if (q['disponivel'] == 'false') {
        disponivel = false;
      } else {
        throw const ErroApi(400, 'Use disponivel=true ou disponivel=false.');
      }
    }
    final filtro = FiltroItens(
      busca: q['busca'] ?? q['pesquisa'] ?? q['q'],
      categoria: comCategoria ? q['categoria'] : null,
      donoId: comDono ? q['donoId'] : null,
      disponivel: disponivel,
      pagina: pagina,
      limite: limite,
    );
    filtro.validar();
    return filtro;
  }

  Future<Map<String, dynamic>> _lerJson(HttpRequest req) async {
    const maximo = 64 * 1024;
    if (req.contentLength > maximo) {
      throw const ErroApi(413, 'JSON excede 64 KiB.', 'corpo_grande');
    }
    final bytes = <int>[];
    await for (final parte in req) {
      bytes.addAll(parte);
      if (bytes.length > maximo) {
        throw const ErroApi(413, 'JSON excede 64 KiB.', 'corpo_grande');
      }
    }
    final valor = jsonDecode(utf8.decode(bytes));
    if (valor is! Map<String, dynamic>) {
      throw const ErroApi(400, 'Envie um objeto JSON.');
    }
    return valor;
  }

  String _obrigatorio(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is! String || valor.trim().isEmpty) {
      throw ErroApi(400, 'Campo obrigatório: $campo.');
    }
    return valor;
  }

  String? _opcional(Map<String, dynamic> json, String campo) {
    if (!json.containsKey(campo)) return null;
    final valor = json[campo];
    if (valor is! String) throw ErroApi(400, 'Campo deve ser texto: $campo.');
    return valor;
  }

  bool _booleano(Map<String, dynamic> json, String campo, {required bool padrao}) {
    final valor = json[campo];
    if (valor == null && !json.containsKey(campo)) return padrao;
    if (valor is! bool) throw ErroApi(400, 'Campo $campo deve ser true ou false.');
    return valor;
  }

  Map<String, Object?> _detalhes(Map<String, dynamic> json) {
    if (!json.containsKey('detalhes')) return {};
    final valor = json['detalhes'];
    if (valor is! Map<String, dynamic>) {
      throw const ErroApi(400, 'O campo detalhes deve ser um objeto JSON.');
    }
    return Map<String, Object?>.from(valor);
  }

  void _configurarCors(HttpRequest req) {
    final origem = req.headers.value('Origin');
    if (origem != null) {
      final uri = Uri.tryParse(origem);
      final local = uri != null &&
          (uri.host == 'localhost' || uri.host == '127.0.0.1') &&
          (uri.scheme == 'http' || uri.scheme == 'https');
      if (local || origensAdicionais.contains(origem)) {
        req.response.headers.set('Access-Control-Allow-Origin', origem);
        req.response.headers.set('Vary', 'Origin');
      }
    }
    req.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
    req.response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  }

  Future<void> _json(HttpResponse res, int status, Object corpo) async {
    res.statusCode = status;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(corpo));
    await res.close();
  }

  Future<void> _vazio(HttpResponse res) async {
    res.statusCode = 204;
    await res.close();
  }
}
