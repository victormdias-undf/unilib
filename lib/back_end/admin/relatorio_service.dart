import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unilib/back_end/core/app_exception.dart';


class RelatorioService {
  RelatorioService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

 Future<String> exigirAdmin() async{
    final id = _client.auth.currentUser?.id;
    if(id == null){
      throw const AppException("Usuário não authenticado");
    }
    final admin = await _client.from("admins").select("user_id").eq("user_id", id).maybeSingle();
    if(admin == null){
      throw const AppException("Você não é administrador");
    }
    return id;
 }
 Future<String> dadosAlunos() async{
  final emprestados = await _client.from("produtos").select("nome, emprestado_por_aluno_id").not("emprestado_por_aluno_id", "is", null);
  var produtos = "produtos emprestados por alunos: ";
  for(final produto in emprestados){
    produtos += produto["nome"] + ", ";
  }
  return produtos;
 }

 // Estado dos produtos que a biblioteca emprestou (dono = Universidade).
 Future<String> estadoProdutosEmprestados() async{
  final emprestados = await _client
      .from("produtos")
      .select("nome, estado")
      .eq("emprestado", true)
      .not("emprestado_por_aluno_id", "is", null);

  var produtos = "estado dos produtos emprestados pela biblioteca: ";
  for(final produto in emprestados){
    produtos += '${produto["nome"]} (${produto["estado"]}), ';
  }
  return produtos;
 }

 // Produtos da biblioteca que não estão no estado "bom".
 Future<String> produtosForaDoBomEstado() async{
  final ruins = await _client
      .from("produtos")
      .select("nome, estado")
      .not("emprestado_por_aluno_id", "is", null)
      .neq("estado", "bom");

  var produtos = "produtos da biblioteca fora do bom estado: ";
  for(final produto in ruins){
    produtos += '${produto["nome"]} (${produto["estado"]}), ';
  }
  return produtos;
 }

 // Empréstimos da biblioteca com prazo vencido.
 Future<String> emprestimosAtrasados() async{
  final hoje = DateTime.now().toIso8601String().substring(0, 10);
  final atrasados = await _client
      .from("produtos")
      .select("nome, data_entrega")
      .eq("emprestado", true)
      .not("emprestado_por_aluno_id", "is", null)
      .lt("data_entrega", hoje);

  var produtos = "produtos da biblioteca com prazo vencido: ";
  for(final produto in atrasados){
    produtos += '${produto["nome"]} (${produto["data_entrega"]}), ';
  }
  return produtos;
 }

 // Tópicos do fórum com a quantidade de comentários de cada um.
 Future<String> topicosForum() async{
  final topicos = await _client
      .from("topicos_forum")
      .select("nome, created_at, comentarios(count)");

  var forum = "tópicos do fórum: ";
  for(final topico in topicos){
    final comentarios = topico["comentarios"];
    var total = 0;
    if(comentarios is List && comentarios.isNotEmpty){
      total = (comentarios.first["count"] as num?)?.toInt() ?? 0;
    }
    forum += '${topico["nome"]} ($total comentário(s)), ';
  }
  return forum;
 }

 // Junta tudo em um único relatório para a biblioteca.
 Future<String> relatorioCompleto() async{
  await exigirAdmin();

  var relatorio = "relatório da biblioteca:\n";
  relatorio += '${await dadosAlunos()}\n';
  relatorio += '${await estadoProdutosEmprestados()}\n';
  relatorio += '${await produtosForaDoBomEstado()}\n';
  relatorio += '${await emprestimosAtrasados()}\n';
  relatorio += '${await topicosForum()}\n';
  return relatorio;
 }
}