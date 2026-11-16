import 'modelos.dart';

PaginaItens paginar(List<ItemAcervo> itens, FiltroItens filtro) {
  filtro.validar();
  final inicio = (filtro.pagina - 1) * filtro.limite;
  return PaginaItens(
    itens: inicio >= itens.length
        ? const []
        : itens.skip(inicio).take(filtro.limite).toList(),
    total: itens.length,
    pagina: filtro.pagina,
    limite: filtro.limite,
  );
}

void exigirAdministrador(Usuario usuario) {
  if (!usuario.ehAdmin) {
    throw const ErroApi(403, 'Ação permitida apenas a administradores.', 'permissao_negada');
  }
}

void exigirDono(Usuario usuario, ItemAcervo item) {
  if (item.donoId != usuario.id) {
    throw const ErroApi(403, 'Você não pode alterar este item.', 'permissao_negada');
  }
}
