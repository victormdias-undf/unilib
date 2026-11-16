import 'package:test/test.dart';
import 'package:unilib_backend/unilib_backend.dart';

void main() {
  const alunoA = Usuario(id: 'a', cpf: '52998224725', email: 'a@exemplo.com');
  const alunoB = Usuario(id: 'b', cpf: '11144477735', email: 'b@exemplo.com');
  const admin = Usuario(
    id: 'admin', cpf: '39053344705', email: 'admin@exemplo.com', papel: PapeisUsuario.admin);

  late DateTime instante;
  late ServicoBiblioteca biblioteca;
  late ServicoEmprestimos servico;
  late RepositorioEmprestimos emprestimosRepo;
  late String livroId;

  setUp(() async {
    instante = DateTime.utc(2026, 11, 1, 10);
    final itens = ItensEmMemoria.comExemplos();
    emprestimosRepo = EmprestimosEmMemoria();
    biblioteca = ServicoBiblioteca(itens, repositorioEmprestimos: emprestimosRepo);
    servico = ServicoEmprestimos(
      emprestimos: emprestimosRepo,
      biblioteca: biblioteca,
      agora: () => instante,
    );
    livroId = (await biblioteca.listarLivros()).itens.first.id;
  });

  test('emprestar bloqueia exemplar e calcula prazo de 14 dias', () async {
    final emprestimo = await servico.emprestarLivro(administrador: admin, aluno: alunoA, livroId: livroId);
    expect(emprestimo.ativo, isTrue);
    expect(emprestimo.prazoDevolucao, instante.add(const Duration(days: 14)));
    expect(emprestimo.situacaoEm(instante), SituacoesEmprestimo.emDia);
    expect((await biblioteca.detalhar(livroId)).disponivel, isFalse);
    expect((await servico.meusEmprestimos(usuario: alunoA)).total, 1);
    expect((await servico.meusEmprestimos(usuario: alunoB)).total, 0);
    await expectLater(
      servico.emprestarLivro(administrador: admin, aluno: alunoB, livroId: livroId),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
  });

  test('devolução no prazo preserva histórico e disponibiliza o exemplar', () async {
    final primeiro = await servico.emprestarLivro(administrador: admin, aluno: alunoA, livroId: livroId);
    instante = instante.add(const Duration(days: 14));
    final devolvido = await servico.registrarDevolucao(usuario: admin, id: primeiro.id);
    expect(devolvido.situacaoEm(instante), SituacoesEmprestimo.devolvidoNoPrazo);
    expect(devolvido.diasAtrasoEm(instante), 0);
    expect(devolvido.toJson(referencia: instante)['devolvidoNoPrazo'], isTrue);
    expect((await biblioteca.detalhar(livroId)).disponivel, isTrue);
    expect((await servico.meusEmprestimos(usuario: alunoA)).total, 1);
    await expectLater(
      servico.registrarDevolucao(usuario: admin, id: primeiro.id),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
    final segundo = await servico.emprestarLivro(administrador: admin, aluno: alunoB, livroId: livroId);
    expect(segundo.id, isNot(primeiro.id));
  });

  test('atraso é calculado sem tarefa agendada; devolução tardia é registrada', () async {
    final emprestimo = await servico.emprestarLivro(administrador: admin, aluno: alunoA, livroId: livroId);
    instante = instante.add(const Duration(days: 16));
    final emAtraso = await servico.detalhar(usuario: alunoA, id: emprestimo.id);
    expect(emAtraso.situacaoEm(instante), SituacoesEmprestimo.atrasado);
    expect(emAtraso.diasAtrasoEm(instante), 2);
    expect((await servico.listarAtrasados(administrador: admin)).total, 1);
    final retorno = await servico.registrarDevolucao(usuario: admin, id: emprestimo.id);
    expect(retorno.situacaoEm(instante), SituacoesEmprestimo.devolvidoAtrasado);
    expect(retorno.toJson(referencia: instante)['devolvidoNoPrazo'], isFalse);
    expect(retorno.diasAtrasoEm(instante), 2);
    expect((await servico.listarAtrasados(administrador: admin)).total, 0);
  });

  test('aluno consulta os seus; somente admin registra retirada e devolução, lista e renova', () async {
    final emprestimo = await servico.emprestarLivro(administrador: admin, aluno: alunoA, livroId: livroId);
    await expectLater(
      servico.emprestarLivro(administrador: alunoA, aluno: alunoB, livroId: livroId),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    await expectLater(
      servico.registrarDevolucao(usuario: alunoA, id: emprestimo.id),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    await expectLater(
      servico.detalhar(usuario: alunoB, id: emprestimo.id),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    await expectLater(
      servico.registrarDevolucao(usuario: alunoB, id: emprestimo.id),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    await expectLater(
      servico.listarAtrasados(administrador: alunoA),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    await expectLater(
      servico.listarTodos(administrador: alunoA),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    await expectLater(
      servico.renovarPrazo(administrador: alunoA, id: emprestimo.id),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    final renovado = await servico.renovarPrazo(administrador: admin, id: emprestimo.id);
    expect(renovado.prazoDevolucao, instante.add(const Duration(days: 21)));
    expect(renovado.renovacoes, 1);
    await expectLater(
      servico.renovarPrazo(administrador: admin, id: emprestimo.id),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
  });

  test('renovação após prazo não é permitida', () async {
    final emprestimo = await servico.emprestarLivro(administrador: admin, aluno: alunoA, livroId: livroId);
    instante = instante.add(const Duration(days: 15));
    await expectLater(
      servico.renovarPrazo(administrador: admin, id: emprestimo.id),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
  });

  test('não empresta eletrônicos, indisponíveis ou livro em duplicidade', () async {
    final eletronico = (await biblioteca.listarEletronicos()).itens.first.id;
    await expectLater(
      servico.emprestarLivro(administrador: admin, aluno: alunoA, livroId: eletronico),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 400)),
    );
    await biblioteca.definirDisponibilidade(
      administrador: admin, id: livroId, disponivel: false);
    await expectLater(
      servico.emprestarLivro(administrador: admin, aluno: alunoA, livroId: livroId),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
  });

  test('admin não pode disponibilizar nem excluir livro enquanto emprestado', () async {
    await servico.emprestarLivro(administrador: admin, aluno: alunoA, livroId: livroId);
    await expectLater(
      biblioteca.definirDisponibilidade(administrador: admin, id: livroId, disponivel: true),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
    await expectLater(
      biblioteca.excluirItem(administrador: admin, id: livroId),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
  });

  test('aluno com empréstimo ativo vencido não pode retirar outro livro', () async {
    final outroLivroId = (await biblioteca.listarLivros()).itens[1].id;
    final primeiro = await servico.emprestarLivro(
      administrador: admin, aluno: alunoA, livroId: livroId);
    instante = instante.add(const Duration(days: 15));

    await expectLater(
      servico.verificarPendenciasAluno(aluno: alunoA),
      throwsA(isA<ErroApi>()
        .having((e) => e.status, 'status', 409)
        .having((e) => e.codigo, 'codigo', 'aluno_com_emprestimo_atrasado')),
    );
    await expectLater(
      servico.emprestarLivro(
        administrador: admin, aluno: alunoA, livroId: outroLivroId),
      throwsA(isA<ErroApi>()
        .having((e) => e.status, 'status', 409)
        .having((e) => e.codigo, 'codigo', 'aluno_com_emprestimo_atrasado')),
    );
    expect((await biblioteca.detalhar(outroLivroId)).disponivel, isTrue);
    expect((await servico.meusEmprestimos(usuario: alunoA)).total, 1);

    // Após a devolução, mesmo atrasada, o aluno volta a estar regular.
    final devolvido = await servico.registrarDevolucao(
      usuario: admin, id: primeiro.id);
    expect(devolvido.situacaoEm(instante), SituacoesEmprestimo.devolvidoAtrasado);
    await servico.verificarPendenciasAluno(aluno: alunoA);
    final novo = await servico.emprestarLivro(
      administrador: admin, aluno: alunoA, livroId: outroLivroId);
    expect(novo.ativo, isTrue);
  });

  test('empréstimo ainda no prazo não bloqueia outros empréstimos', () async {
    final outroLivroId = (await biblioteca.listarLivros()).itens[1].id;
    await servico.emprestarLivro(
      administrador: admin, aluno: alunoA, livroId: livroId);
    // Exatamente no vencimento ainda está em dia.
    instante = instante.add(const Duration(days: 14));
    await servico.verificarPendenciasAluno(aluno: alunoA);
    final segundo = await servico.emprestarLivro(
      administrador: admin, aluno: alunoA, livroId: outroLivroId);
    expect(segundo.ativo, isTrue);
    expect((await servico.meusEmprestimos(usuario: alunoA)).total, 2);
  });

  test('atraso de um aluno não bloqueia aluno diferente', () async {
    final outroLivroId = (await biblioteca.listarLivros()).itens[1].id;
    await servico.emprestarLivro(
      administrador: admin, aluno: alunoA, livroId: livroId);
    instante = instante.add(const Duration(days: 16));
    await servico.verificarPendenciasAluno(aluno: alunoB);
    final segundo = await servico.emprestarLivro(
      administrador: admin, aluno: alunoB, livroId: outroLivroId);
    expect(segundo.usuarioId, alunoB.id);
  });

  test('erro de paginação é tratado', () async {
    await expectLater(
      servico.meusEmprestimos(usuario: alunoA, limite: 0),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 400)),
    );
  });
}
