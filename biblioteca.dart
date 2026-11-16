import '../contratos.dart';
import '../identificadores.dart';
import '../listagens.dart';
import '../modelos.dart';
import '../validacoes.dart';

/// Funções prontas para serem reutilizadas pelo backend, frontend e testes.
/// O frontend usa as rotas HTTP correspondentes (não importa código Dart).
class ServicoBiblioteca {
  final RepositorioItens itens;
  final RepositorioEmprestimos? repositorioEmprestimos;
  const ServicoBiblioteca(this.itens, {this.repositorioEmprestimos});

  Future<PaginaItens> listarBiblioteca([FiltroItens filtro = const FiltroItens()]) async {
    filtro.validar();
    if (filtro.categoria != null && !CategoriasBiblioteca.valida(filtro.categoria!)) {
      throw const ErroApi(400, 'Categoria inválida.', 'categoria_invalida');
    }
    final lista = await itens.listar(
      origem: 'biblioteca',
      busca: filtro.busca,
      categoria: filtro.categoria,
      disponivel: filtro.disponivel,
    );
    return paginar(lista, filtro);
  }

  Future<PaginaItens> listarLivros([FiltroItens filtro = const FiltroItens()]) =>
      listarBiblioteca(_naCategoria(filtro, CategoriasBiblioteca.livros));

  Future<PaginaItens> listarEletronicos([FiltroItens filtro = const FiltroItens()]) =>
      listarBiblioteca(_naCategoria(filtro, CategoriasBiblioteca.eletronicos));

  Future<PaginaItens> listarItensGerais([FiltroItens filtro = const FiltroItens()]) =>
      listarBiblioteca(_naCategoria(filtro, CategoriasBiblioteca.itensGerais));

  Future<PaginaItens> listarSalas([FiltroItens filtro = const FiltroItens()]) =>
      listarBiblioteca(_naCategoria(filtro, CategoriasBiblioteca.salas));

  FiltroItens _naCategoria(FiltroItens filtro, String categoria) => FiltroItens(
        busca: filtro.busca,
        categoria: categoria,
        disponivel: filtro.disponivel,
        pagina: filtro.pagina,
        limite: filtro.limite,
      );

  Future<ItemAcervo> detalhar(String id) async {
    final item = await itens.buscar('biblioteca', id);
    if (item == null) {
      throw const ErroApi(404, 'Item da biblioteca não encontrado.', 'item_nao_encontrado');
    }
    return item;
  }

  /// Pode ser utilizado pelo painel de administração do restante da equipe.
  Future<ItemAcervo> cadastrarItem({
    required Usuario administrador,
    required String categoria,
    required String nome,
    String descricao = '',
    bool disponivel = true,
    Map<String, Object?> detalhes = const {},
  }) async {
    exigirAdministrador(administrador);
    _categoriaValida(categoria);
    final agora = DateTime.now().toUtc();
    final item = ItemAcervo(
      id: gerarIdentificador(),
      nome: Validacoes.nome(nome),
      descricao: Validacoes.descricao(descricao),
      origem: 'biblioteca',
      categoria: categoria,
      disponivel: disponivel,
      detalhes: validarDetalhes(detalhes),
      criadoEm: agora,
      atualizadoEm: agora,
    );
    return itens.inserir(item);
  }

  Future<ItemAcervo> cadastrarLivro({required Usuario administrador, required String nome,
    String descricao = '', bool disponivel = true, Map<String, Object?> detalhes = const {}}) =>
    cadastrarItem(administrador: administrador, categoria: CategoriasBiblioteca.livros,
      nome: nome, descricao: descricao, disponivel: disponivel, detalhes: detalhes);

  Future<ItemAcervo> cadastrarEletronico({required Usuario administrador, required String nome,
    String descricao = '', bool disponivel = true, Map<String, Object?> detalhes = const {}}) =>
    cadastrarItem(administrador: administrador, categoria: CategoriasBiblioteca.eletronicos,
      nome: nome, descricao: descricao, disponivel: disponivel, detalhes: detalhes);

  Future<ItemAcervo> cadastrarItemGeral({required Usuario administrador, required String nome,
    String descricao = '', bool disponivel = true, Map<String, Object?> detalhes = const {}}) =>
    cadastrarItem(administrador: administrador, categoria: CategoriasBiblioteca.itensGerais,
      nome: nome, descricao: descricao, disponivel: disponivel, detalhes: detalhes);

  Future<ItemAcervo> cadastrarSala({required Usuario administrador, required String nome,
    String descricao = '', bool disponivel = true, Map<String, Object?> detalhes = const {}}) =>
    cadastrarItem(administrador: administrador, categoria: CategoriasBiblioteca.salas,
      nome: nome, descricao: descricao, disponivel: disponivel, detalhes: detalhes);

  Future<ItemAcervo> atualizarItem({
    required Usuario administrador,
    required String id,
    String? nome,
    String? descricao,
    String? categoria,
    bool? disponivel,
    Map<String, Object?>? detalhes,
  }) async {
    exigirAdministrador(administrador);
    final atual = await detalhar(id);
    if (atual.categoria == CategoriasBiblioteca.livros &&
        repositorioEmprestimos != null) {
      final ativo = await repositorioEmprestimos!.ativoDoLivro(id);
      if (ativo != null && (disponivel == true ||
          (categoria != null && categoria != CategoriasBiblioteca.livros))) {
        throw const ErroApi(409,
          'Não é possível disponibilizar ou mudar a categoria de um livro emprestado.',
          'livro_emprestado');
      }
    }
    if (categoria != null) _categoriaValida(categoria);
    final atualizado = atual.copiarCom(
      nome: nome == null ? null : Validacoes.nome(nome),
      descricao: descricao == null ? null : Validacoes.descricao(descricao),
      categoria: categoria,
      disponivel: disponivel,
      detalhes: detalhes == null ? null : validarDetalhes(detalhes),
    );
    final salvo = await itens.salvar(atualizado);
    if (salvo == null) throw const ErroApi(404, 'Item não encontrado.');
    return salvo;
  }

  Future<ItemAcervo> definirDisponibilidade({
    required Usuario administrador,
    required String id,
    required bool disponivel,
  }) => atualizarItem(administrador: administrador, id: id, disponivel: disponivel);

  Future<void> excluirItem({required Usuario administrador, required String id}) async {
    exigirAdministrador(administrador);
    if (repositorioEmprestimos != null) {
      final historico = await repositorioEmprestimos!.listar();
      if (historico.any((e) => e.livroId == id)) {
        throw const ErroApi(409,
          'Livro com histórico de empréstimos não pode ser excluído.',
          'livro_com_historico');
      }
    }
    if (!await itens.remover('biblioteca', id)) {
      throw const ErroApi(404, 'Item não encontrado.');
    }
  }

  void _categoriaValida(String categoria) {
    if (!CategoriasBiblioteca.valida(categoria)) {
      throw const ErroApi(400, 'Categoria inválida. Use Livros, Eletrônicos, Itens Gerais ou Salas.');
    }
  }
}

/// Detalhes opcionais e portáteis entre bancos (somente JSON simples).
Map<String, Object?> validarDetalhes(Map<String, Object?> detalhes) {
  if (detalhes.length > 20) {
    throw const ErroApi(400, 'detalhes aceita no máximo 20 campos.');
  }
  final validado = <String, Object?>{};
  for (final entrada in detalhes.entries) {
    if (entrada.key.isEmpty || entrada.key.length > 40) {
      throw const ErroApi(400, 'Chave de detalhe inválida.');
    }
    final valor = entrada.value;
    if (valor != null && valor is! String && valor is! num && valor is! bool) {
      throw const ErroApi(400, 'Detalhes devem ter valores de texto, número ou booleano.');
    }
    if (valor is String && valor.length > 500) {
      throw const ErroApi(400, 'Valor de detalhe excede 500 caracteres.');
    }
    validado[entrada.key] = valor;
  }
  return validado;
}
