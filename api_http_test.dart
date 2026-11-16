import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:unilib_backend/unilib_backend.dart';

void main() {
  late HttpServer servidor;
  late HttpClient cliente;
  late Uri base;
  late String tokenAdmin;

  Future<({int status, Map<String, dynamic> dados})> enviar(
    String metodo,
    String caminho, {
    Map<String, Object?>? corpo,
    String? token,
  }) async {
    final req = await cliente.openUrl(metodo, base.resolve(caminho));
    if (token != null) req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    if (corpo != null) {
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(corpo));
    }
    final res = await req.close();
    final texto = await utf8.decoder.bind(res).join();
    return (status: res.statusCode, dados: texto.isEmpty ? <String, dynamic>{} : jsonDecode(texto) as Map<String, dynamic>);
  }

  setUp(() async {
    final usuarios = UsuariosEmMemoria();
    final sessoes = SessoesEmMemoria();
    final itens = ItensEmMemoria.comExemplos();
    final auth = ServicoAutenticacao(usuarios: usuarios, sessoes: sessoes);
    await auth.cadastrarAdminInicial(
      cpf: '39053344705', email: 'admin@exemplo.com', senha: 'AdminTeste123');
    tokenAdmin = (await auth.entrar(
      cpf: '39053344705', senha: 'AdminTeste123')).token;
    final repoEmprestimos = EmprestimosEmMemoria();
    final biblioteca = ServicoBiblioteca(itens, repositorioEmprestimos: repoEmprestimos);
    final api = ApiUniLib(
      autenticacao: auth,
      biblioteca: biblioteca,
      acervo: ServicoAcervoAlunos(itens),
      favoritos: ServicoFavoritosLivros(
        repositorio: FavoritosLivrosEmMemoria(), biblioteca: biblioteca),
      emprestimos: ServicoEmprestimos(emprestimos: repoEmprestimos, biblioteca: biblioteca),
    );
    servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    servidor.listen((req) { api.atender(req); });
    cliente = HttpClient();
    base = Uri.parse('http://127.0.0.1:${servidor.port}/');
  });

  tearDown(() async {
    cliente.close(force: true);
    await servidor.close(force: true);
  });

  test('health e categorias entregam JSON para frontend', () async {
    final health = await enviar('GET', '/api/health');
    expect(health.status, 200);
    expect(health.dados['status'], 'ok');
    final livros = await enviar('GET', '/api/biblioteca/livros?pagina=1&limite=5');
    expect(livros.status, 200);
    expect(livros.dados['total'], 12);
    expect((livros.dados['itens'] as List).length, 5);
  });

  test('cadastro, login e escrita no próprio acervo', () async {
    final cadastro = await enviar('POST', '/api/auth/cadastro', corpo: {
      'cpf': '52998224725', 'email': 'aluno@exemplo.com', 'senha': 'SenhaTeste123'});
    expect(cadastro.status, 201);
    final login = await enviar('POST', '/api/auth/login', corpo: {
      'cpf': '52998224725', 'senha': 'SenhaTeste123'});
    expect(login.status, 200);
    final token = login.dados['token'] as String;
    final criado = await enviar('POST', '/api/acervo-alunos', token: token,
        corpo: {'nome': 'Meu Atlas', 'descricao': 'Exemplar pessoal',
          'contato': 'contato@exemplo.com'});
    expect(criado.status, 201);
    expect((criado.dados['item'] as Map)['contato'], 'contato@exemplo.com');
    final semContato = await enviar('POST', '/api/acervo-alunos', token: token,
      corpo: {'nome': 'Sem contato'});
    expect(semContato.status, 400);
    final meus = await enviar('GET', '/api/acervo-alunos/meus', token: token);
    expect(meus.dados['total'], 1);
    final id = (criado.dados['item'] as Map)['id'] as String;
    final edicao = await enviar('PATCH', '/api/acervo-alunos/$id/disponibilidade',
        token: token, corpo: {'disponivel': false});
    expect((edicao.dados['item'] as Map)['disponivel'], isFalse);
    final emprestimoDoAcervo = await enviar('POST', '/api/emprestimos',
        token: tokenAdmin, corpo: {'livroId': id, 'cpfAluno': '52998224725'});
    expect(emprestimoDoAcervo.status, 404);
    final bloqueado = await enviar('POST', '/api/biblioteca/livros', token: token,
        corpo: {'nome': 'Tentativa proibida'});
    expect(bloqueado.status, 403);
  });

  test('API: favoritos requerem token e pertencem a cada usuario', () async {
    final livros = await enviar('GET', '/api/biblioteca/livros?limite=1');
    final livroId = ((livros.dados['itens'] as List).first as Map)['id'] as String;
    final eletronicos = await enviar('GET', '/api/biblioteca/eletronicos?limite=1');
    final eletronicoId = ((eletronicos.dados['itens'] as List).first as Map)['id'] as String;

    final semToken = await enviar('POST', '/api/favoritos/livros/$livroId');
    expect(semToken.status, 401);

    Future<String> cadastroLogin(String cpf, String email) async {
      final cadastro = await enviar('POST', '/api/auth/cadastro', corpo: {
        'cpf': cpf, 'email': email, 'senha': 'SenhaTeste123',
      });
      expect(cadastro.status, 201);
      final login = await enviar('POST', '/api/auth/login', corpo: {
        'cpf': cpf, 'senha': 'SenhaTeste123',
      });
      expect(login.status, 200);
      return login.dados['token'] as String;
    }

    final tokenA = await cadastroLogin('52998224725', 'aluno1@exemplo.com');
    final tokenB = await cadastroLogin('11144477735', 'aluno2@exemplo.com');

    final adicionado = await enviar('POST', '/api/favoritos/livros/$livroId', token: tokenA);
    expect(adicionado.status, 201);
    expect(adicionado.dados['favorito'], isTrue);
    final repetido = await enviar('POST', '/api/favoritos/livros/$livroId', token: tokenA);
    expect(repetido.status, 200);
    expect(repetido.dados['adicionado'], isFalse);

    final listaA = await enviar('GET', '/api/favoritos/livros', token: tokenA);
    final listaB = await enviar('GET', '/api/favoritos/livros', token: tokenB);
    expect(listaA.dados['total'], 1);
    expect(listaB.dados['total'], 0);
    final checaA = await enviar('GET', '/api/favoritos/livros/$livroId', token: tokenA);
    final checaB = await enviar('GET', '/api/favoritos/livros/$livroId', token: tokenB);
    expect(checaA.dados['favorito'], isTrue);
    expect(checaB.dados['favorito'], isFalse);

    final invalido = await enviar('POST', '/api/favoritos/livros/$eletronicoId', token: tokenA);
    expect(invalido.status, 400);

    final apagado = await enviar('DELETE', '/api/favoritos/livros/$livroId', token: tokenA);
    expect(apagado.status, 204);
    final removido = await enviar('GET', '/api/favoritos/livros/$livroId', token: tokenA);
    expect(removido.dados['favorito'], isFalse);
  });

  test('API emprestimos: pegar, consultar prazo, devolver e proteger acesso', () async {
    final livros = await enviar('GET', '/api/biblioteca/livros?limite=1');
    final livroId = ((livros.dados['itens'] as List).first as Map)['id'] as String;

    Future<String> loginAluno(String cpf, String email) async {
      final cadastro = await enviar('POST', '/api/auth/cadastro', corpo: {
        'cpf': cpf, 'email': email, 'senha': 'SenhaTeste123',
      });
      expect(cadastro.status, 201);
      final login = await enviar('POST', '/api/auth/login', corpo: {
        'cpf': cpf, 'senha': 'SenhaTeste123',
      });
      return login.dados['token'] as String;
    }

    final tokenA = await loginAluno('52998224725', 'alunoA@exemplo.com');
    final tokenB = await loginAluno('11144477735', 'alunoB@exemplo.com');
    final anonimo = await enviar('POST', '/api/emprestimos', corpo: {'livroId': livroId});
    expect(anonimo.status, 401);
    final alunoNaoPodeEmprestar = await enviar('POST', '/api/emprestimos', token: tokenA,
        corpo: {'livroId': livroId, 'cpfAluno': '52998224725'});
    expect(alunoNaoPodeEmprestar.status, 403);
    final cpfInvalido = await enviar('POST', '/api/emprestimos', token: tokenAdmin,
        corpo: {'livroId': livroId, 'cpfAluno': '123'});
    expect(cpfInvalido.status, 400);
    final novo = await enviar('POST', '/api/emprestimos', token: tokenAdmin,
        corpo: {'livroId': livroId, 'cpfAluno': '52998224725'});
    expect(novo.status, 201);
    final emprestimo = novo.dados['emprestimo'] as Map;
    expect(emprestimo['situacao'], SituacoesEmprestimo.emDia);
    expect(emprestimo['usuarioId'], isA<String>());
    expect(emprestimo['prazoDevolucao'], isA<String>());
    final emprestimoId = emprestimo['id'] as String;

    final livro = await enviar('GET', '/api/biblioteca/$livroId');
    expect((livro.dados['item'] as Map)['disponivel'], isFalse);
    final segundaTentativa = await enviar('POST', '/api/emprestimos', token: tokenAdmin,
        corpo: {'livroId': livroId, 'cpfAluno': '11144477735'});
    expect(segundaTentativa.status, 409);
    final meusA = await enviar('GET', '/api/emprestimos/meus', token: tokenA);
    final meusB = await enviar('GET', '/api/emprestimos/meus', token: tokenB);
    expect(meusA.dados['total'], 1);
    expect(meusB.dados['total'], 0);
    final proibido = await enviar('GET', '/api/emprestimos/$emprestimoId', token: tokenB);
    expect(proibido.status, 403);
    final atrasadosProibido = await enviar('GET', '/api/emprestimos/atrasados', token: tokenA);
    expect(atrasadosProibido.status, 403);
    final devolucaoProibida = await enviar('POST', '/api/emprestimos/$emprestimoId/devolucao',
        token: tokenB);
    expect(devolucaoProibida.status, 403);
    final alunoNaoPodeDevolver = await enviar('POST', '/api/emprestimos/$emprestimoId/devolucao',
        token: tokenA);
    expect(alunoNaoPodeDevolver.status, 403);
    final devolucao = await enviar('POST', '/api/emprestimos/$emprestimoId/devolucao',
        token: tokenAdmin);
    expect(devolucao.status, 200);
    expect((devolucao.dados['emprestimo'] as Map)['situacao'],
        SituacoesEmprestimo.devolvidoNoPrazo);
    final livroDevolvido = await enviar('GET', '/api/biblioteca/$livroId');
    expect((livroDevolvido.dados['item'] as Map)['disponivel'], isTrue);
  });

}
