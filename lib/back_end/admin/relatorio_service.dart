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
}