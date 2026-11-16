import '../contratos.dart';
import '../identificadores.dart';
import '../listagens.dart';
import '../modelos.dart';
import '../validacoes.dart';
import 'biblioteca.dart';

/// Regras do Acervo dos Alunos, que NÃO possui categorias.
class ServicoAcervoAlunos {
  final RepositorioItens itens;
  const ServicoAcervoAlunos(this.itens);

  Future<PaginaItens> listarAcervo([FiltroItens filtro = const FiltroItens()]) async {
    filtro.validar();
    final resultado = await itens.listar(
      origem: 'alunos',
      busca: filtro.busca,
      disponivel: filtro.disponivel,
      donoId: filtro.donoId,
    );
    return paginar(resultado, filtro);
  }

  Future<PaginaItens> listarMeusItens(
    Usuario usuario, [FiltroItens filtro = const FiltroItens()]
  ) => listarAcervo(FiltroItens(
        busca: filtro.busca,
        disponivel: filtro.disponivel,
        donoId: usuario.id,
        pagina: filtro.pagina,
        limite: filtro.limite,
      ));

  Future<ItemAcervo> detalhar(String id) async {
    final item = await itens.buscar('alunos', id);
    if (item == null) {
      throw const ErroApi(404, 'Item do acervo não encontrado.', 'item_nao_encontrado');
    }
    return item;
  }

  Future<ItemAcervo> cadastrarItem({
    required Usuario usuario,
    required String nome,
    required String contato,
    required String descricao,
    bool disponivel = true,
    Map<String, Object?> detalhes = const {},
  }) async {
    final agora = DateTime.now().toUtc();
    return itens.inserir(ItemAcervo(
      id: gerarIdentificador(),
      nome: Validacoes.nome(nome),
      descricao: Validacoes.descricaoAnuncio(descricao),
      origem: 'alunos',
      donoId: usuario.id,
      contato: Validacoes.contato(contato),
      disponivel: disponivel,
      detalhes: validarDetalhes(detalhes),
      criadoEm: agora,
      atualizadoEm: agora,
    ));
  }

  Future<ItemAcervo> atualizarItem({
    required Usuario usuario,
    required String id,
    String? nome,
    String? descricao,
    String? contato,
    bool? disponivel,
    Map<String, Object?>? detalhes,
  }) async {
    final atual = await detalhar(id);
    exigirDono(usuario, atual);
    final atualizado = atual.copiarCom(
      nome: nome == null ? null : Validacoes.nome(nome),
      descricao: descricao == null ? null : Validacoes.descricaoAnuncio(descricao),
      contato: contato == null ? null : Validacoes.contato(contato),
      disponivel: disponivel,
      detalhes: detalhes == null ? null : validarDetalhes(detalhes),
    );
    final salvo = await itens.salvar(atualizado);
    if (salvo == null) throw const ErroApi(404, 'Item não encontrado.');
    return salvo;
  }

  Future<ItemAcervo> definirDisponibilidade({
    required Usuario usuario,
    required String id,
    required bool disponivel,
  }) => atualizarItem(usuario: usuario, id: id, disponivel: disponivel);

  Future<void> excluirItem({required Usuario usuario, required String id}) async {
    final item = await detalhar(id);
    exigirDono(usuario, item);
    if (!await itens.remover('alunos', id)) throw const ErroApi(404, 'Item não encontrado.');
  }
}
