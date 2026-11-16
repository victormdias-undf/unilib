import 'package:test/test.dart';
import 'package:unilib_backend/unilib_backend.dart';

void main() {
  final admin = Usuario(id: 'adm', cpf: '52998224725', email: 'adm@exemplo.com', papel: 'admin');
  final aluno = Usuario(id: 'alu', cpf: '52998224725', email: 'alu@exemplo.com');

  test('separa todas as categorias e filtra por busca', () async {
    final servico = ServicoBiblioteca(ItensEmMemoria.comExemplos());
    expect((await servico.listarLivros()).total, 12);
    expect((await servico.listarEletronicos()).total, 6);
    expect((await servico.listarItensGerais()).total, 9);
    expect((await servico.listarSalas()).total, 4);
    expect((await servico.listarBiblioteca()).total, 31);
    expect((await servico.listarLivros(const FiltroItens(busca: 'Livro 1'))).total, greaterThan(0));
  });

  test('paginação funciona', () async {
    final servico = ServicoBiblioteca(ItensEmMemoria.comExemplos());
    final p = await servico.listarLivros(const FiltroItens(pagina: 2, limite: 5));
    expect(p.total, 12);
    expect(p.itens.length, 5);
    expect(p.toJson()['totalPaginas'], 3);
  });

  test('apenas administrador altera a biblioteca', () async {
    final servico = ServicoBiblioteca(ItensEmMemoria());
    await expectLater(
      servico.cadastrarLivro(administrador: aluno, nome: 'Livro proibido'),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 403)),
    );
    final item = await servico.cadastrarLivro(
      administrador: admin, nome: 'Atlas', detalhes: {'autor': 'Equipe UniLib'});
    expect(item.categoria, 'Livros');
    final alterado = await servico.definirDisponibilidade(
      administrador: admin, id: item.id, disponivel: false);
    expect(alterado.disponivel, isFalse);
    final atualizado = await servico.atualizarItem(
      administrador: admin, id: item.id, nome: 'Atlas completo');
    expect(atualizado.nome, 'Atlas completo');
    await servico.excluirItem(administrador: admin, id: item.id);
    await expectLater(servico.detalhar(item.id), throwsA(isA<ErroApi>()));
  });
}
