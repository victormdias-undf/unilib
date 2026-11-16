import 'package:test/test.dart';
import 'package:unilib_backend/unilib_backend.dart';

void main() {
  final alunoA = Usuario(id: 'aluno-a', cpf: '52998224725', email: 'a@exemplo.com');
  final alunoB = Usuario(id: 'aluno-b', cpf: '11144477735', email: 'b@exemplo.com');

  test('cada aluno gerencia apenas seus itens', () async {
    final servico = ServicoAcervoAlunos(ItensEmMemoria());
    final item = await servico.cadastrarItem(usuario: alunoA, nome: 'Meu livro', contato: 'email@exemplo.com', descricao: 'Livro em ótimo estado');
    expect(item.categoria, isNull);
    expect(item.contato, 'email@exemplo.com');
    expect(item.descricao, 'Livro em ótimo estado');
    expect((await servico.listarMeusItens(alunoA)).total, 1);
    expect((await servico.listarMeusItens(alunoB)).total, 0);
    await expectLater(
      servico.atualizarItem(usuario: alunoB, id: item.id, nome: 'Não pode'),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    final alterado = await servico.definirDisponibilidade(
      usuario: alunoA, id: item.id, disponivel: false);
    expect(alterado.disponivel, isFalse);
    expect(alterado.contato, 'email@exemplo.com');
    await servico.excluirItem(usuario: alunoA, id: item.id);
    expect((await servico.listarAcervo()).total, 0);
  });

  test('pesquisa e filtro disponíveis funcionam', () async {
    final servico = ServicoAcervoAlunos(ItensEmMemoria());
    await servico.cadastrarItem(usuario: alunoA, nome: 'Atlas de Anatomia', contato: '11 99999-9999', descricao: 'Em ótimo estado');
    await servico.cadastrarItem(usuario: alunoB, nome: 'Calculadora', contato: '@contato', descricao: 'Calculadora em uso', disponivel: false);
    expect((await servico.listarAcervo(const FiltroItens(busca: 'Atlas'))).total, 1);
    expect((await servico.listarAcervo(const FiltroItens(disponivel: false))).total, 1);
  });

  test('contato é obrigatório e somente dono edita contato', () async {
    final servico = ServicoAcervoAlunos(ItensEmMemoria());
    await expectLater(
      servico.cadastrarItem(usuario: alunoA, nome: 'Sem contato', contato: ' ', descricao: 'Descrição válida'),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 400)),
    );
    await expectLater(
      servico.cadastrarItem(usuario: alunoA, nome: 'Sem descrição', contato: 'x@y.com', descricao: ' '),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 400)),
    );
    final anuncio = await servico.cadastrarItem(
      usuario: alunoA, nome: 'Caderno', contato: 'contato@exemplo.com',
      descricao: 'Retirada a combinar',
    );
    await expectLater(
      servico.atualizarItem(usuario: alunoB, id: anuncio.id, contato: 'outro@exemplo.com'),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    final atualizado = await servico.atualizarItem(
      usuario: alunoA, id: anuncio.id, contato: '55 61 99999-9999');
    expect(atualizado.toJson()['contato'], '55 61 99999-9999');
  });

}
