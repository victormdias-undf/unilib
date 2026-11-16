import 'package:test/test.dart';
import 'package:unilib_backend/unilib_backend.dart';

void main() {
  const usuarioA = Usuario(id: 'aluno-a', cpf: '52998224725', email: 'a@exemplo.com');
  const usuarioB = Usuario(id: 'aluno-b', cpf: '11144477735', email: 'b@exemplo.com');

  late ServicoBiblioteca biblioteca;
  late ServicoFavoritosLivros favoritos;

  setUp(() {
    final itens = ItensEmMemoria.comExemplos();
    biblioteca = ServicoBiblioteca(itens);
    favoritos = ServicoFavoritosLivros(
      repositorio: FavoritosLivrosEmMemoria(),
      biblioteca: biblioteca,
    );
  });

  test('favoritos são individuais, sem duplicação, e podem ser removidos', () async {
    final livros = await biblioteca.listarLivros();
    final livroId = livros.itens.first.id;

    expect(await favoritos.favoritarLivro(usuario: usuarioA, livroId: livroId), isTrue);
    expect(await favoritos.favoritarLivro(usuario: usuarioA, livroId: livroId), isFalse);
    expect(await favoritos.verificarFavorito(usuario: usuarioA, livroId: livroId), isTrue);
    expect(await favoritos.verificarFavorito(usuario: usuarioB, livroId: livroId), isFalse);
    expect((await favoritos.listarFavoritos(usuario: usuarioA)).total, 1);
    expect((await favoritos.listarFavoritos(usuario: usuarioB)).total, 0);

    expect(await favoritos.desfavoritarLivro(usuario: usuarioA, livroId: livroId), isTrue);
    expect(await favoritos.desfavoritarLivro(usuario: usuarioA, livroId: livroId), isFalse);
    expect((await favoritos.listarFavoritos(usuario: usuarioA)).total, 0);
  });

  test('livros inexistentes e categorias diferentes são rejeitados', () async {
    final eletronic = (await biblioteca.listarEletronicos()).itens.first;
    await expectLater(
      favoritos.favoritarLivro(usuario: usuarioA, livroId: eletronic.id),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 400)),
    );
    await expectLater(
      favoritos.favoritarLivro(usuario: usuarioA, livroId: 'livro-inexistente'),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 404)),
    );
  });

  test('listagem de favoritos aceita busca, disponibilidade e paginação', () async {
    final livros = await biblioteca.listarLivros();
    final livro1 = livros.itens.first;
    final livro2 = livros.itens[1];
    await favoritos.favoritarLivro(usuario: usuarioA, livroId: livro1.id);
    await favoritos.favoritarLivro(usuario: usuarioA, livroId: livro2.id);

    final paginado = await favoritos.listarFavoritos(
      usuario: usuarioA,
      filtro: const FiltroItens(pagina: 2, limite: 1),
    );
    expect(paginado.total, 2);
    expect(paginado.itens.length, 1);
    final busca = await favoritos.listarFavoritos(
      usuario: usuarioA,
      filtro: FiltroItens(busca: livro1.nome),
    );
    expect(busca.itens.any((item) => item.id == livro1.id), isTrue);
  });
}
