import '../contratos.dart';
import '../listagens.dart';
import '../modelos.dart';
import 'biblioteca.dart';

/// Favoritos pessoais de livros da Biblioteca Geral.
/// Sempre usa o ID do usuário autenticado; não permite favoritar em nome de outro.
class ServicoFavoritosLivros {
  final RepositorioFavoritosLivros repositorio;
  final ServicoBiblioteca biblioteca;

  const ServicoFavoritosLivros({required this.repositorio, required this.biblioteca});

  Future<ItemAcervo> _exigirLivro(String livroId) async {
    final item = await biblioteca.detalhar(livroId);
    if (item.categoria != CategoriasBiblioteca.livros) {
      throw const ErroApi(400, 'Apenas livros da Biblioteca Geral podem ser favoritados.', 'item_nao_e_livro');
    }
    return item;
  }

  /// Adiciona aos favoritos. Repetir a operação não cria duplicatas.
  Future<bool> favoritarLivro({required Usuario usuario, required String livroId}) async {
    await _exigirLivro(livroId);
    return repositorio.adicionarLivro(usuarioId: usuario.id, livroId: livroId);
  }

  /// Remove dos favoritos, inclusive se o livro foi apagado da biblioteca.
  /// Repetir a operação é seguro.
  Future<bool> desfavoritarLivro({required Usuario usuario, required String livroId}) {
    return repositorio.removerLivro(usuarioId: usuario.id, livroId: livroId);
  }

  /// Consulta se um livro existente está favoritado pelo usuário.
  Future<bool> verificarFavorito({required Usuario usuario, required String livroId}) async {
    await _exigirLivro(livroId);
    return repositorio.contemLivro(usuarioId: usuario.id, livroId: livroId);
  }

  /// Lista os livros favoritos com os campos normais da biblioteca.
  /// Filtra apenas livros existentes; a equipe do banco deve fazer ON DELETE CASCADE.
  Future<PaginaItens> listarFavoritos({
    required Usuario usuario,
    FiltroItens filtro = const FiltroItens(),
  }) async {
    filtro.validar();
    final ids = await repositorio.listarIdsLivros(usuarioId: usuario.id);
    final lista = <ItemAcervo>[];
    final busca = (filtro.busca ?? '').trim().toLowerCase();
    for (final id in ids) {
      final livro = await biblioteca.itens.buscar('biblioteca', id);
      if (livro == null || livro.categoria != CategoriasBiblioteca.livros) continue;
      if (filtro.disponivel != null && livro.disponivel != filtro.disponivel) continue;
      if (busca.isNotEmpty &&
          !'${livro.nome} ${livro.descricao}'.toLowerCase().contains(busca)) continue;
      lista.add(livro);
    }
    lista.sort((a, b) {
      final porNome = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      return porNome != 0 ? porNome : a.id.compareTo(b.id);
    });
    return paginar(lista, filtro);
  }
}
