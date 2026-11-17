import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:unilib/back_end/core/app_exception.dart';
import 'protocolo.dart';

/// Back end do Protocolo (item 4): reclamação ou elogio com título,
/// descrição e imagem opcional.
class ProtocoloService {
  ProtocoloService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _bucket = 'protocolos';
  static const _tituloMax = 150;
  static const _descricaoMax = 5000;
  static const _imagemMaxBytes = 5 * 1024 * 1024; // 5 MB

  static const _tiposImagem = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  String _exigirLogin() {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Você precisa estar logado para continuar.');
    }
    return id;
  }

  /// Registra um protocolo. A imagem é opcional: passe [imagemBytes] e
  /// [nomeImagem] (com extensão) juntos. Funciona em mobile e web.
  Future<Protocolo> enviar({
    required TipoProtocolo tipo,
    required String titulo,
    required String descricao,
    Uint8List? imagemBytes,
    String? nomeImagem,
  }) {
    final usuarioId = _exigirLogin();

    final t = titulo.trim();
    final d = descricao.trim();

    if (t.length < 3) {
      throw const AppException('O título precisa ter ao menos 3 caracteres.');
    }
    if (t.length > _tituloMax) {
      throw const AppException('O título pode ter no máximo $_tituloMax caracteres.');
    }
    if (d.isEmpty) {
      throw const AppException('Escreva uma descrição.');
    }
    if (d.length > _descricaoMax) {
      throw const AppException('A descrição pode ter no máximo $_descricaoMax caracteres.');
    }

    String? extensao;
    if (imagemBytes != null) {
      if (nomeImagem == null || !nomeImagem.contains('.')) {
        throw const AppException('Não foi possível identificar o tipo da imagem.');
      }
      extensao = nomeImagem.split('.').last.toLowerCase();
      if (!_tiposImagem.containsKey(extensao)) {
        throw const AppException('Use uma imagem JPG, PNG ou WEBP.');
      }
      if (imagemBytes.lengthInBytes > _imagemMaxBytes) {
        throw const AppException('A imagem pode ter no máximo 5 MB.');
      }
    }

    return executar(() async {
      String? caminho;

      if (imagemBytes != null && extensao != null) {
        caminho = '$usuarioId/${DateTime.now().microsecondsSinceEpoch}.$extensao';
        await _client.storage.from(_bucket).uploadBinary(
              caminho,
              imagemBytes,
              fileOptions: FileOptions(contentType: _tiposImagem[extensao]),
            );
      }

      try {
        // autor_id e status são definidos pelo banco.
        final dado = await _client
            .from('protocolos')
            .insert({
              'tipo': tipo.valor,
              'titulo': t,
              'descricao': d,
              'imagem_path': caminho,
            })
            .select()
            .single();
        return Protocolo.fromMap(dado);
      } catch (_) {
        // Se o registro falhar, remove a imagem para não deixar arquivo órfão.
        if (caminho != null) {
          try {
            await _client.storage.from(_bucket).remove([caminho]);
          } catch (_) {}
        }
        rethrow;
      }
    }, 'Não foi possível enviar o protocolo.');
  }

  /// Protocolos do usuário logado, do mais novo para o mais antigo.
  /// Use [tipo] para filtrar só reclamações ou só elogios.
  Future<List<Protocolo>> listarMeus({TipoProtocolo? tipo}) {
    _exigirLogin();
    return executar(() async {
      var consulta = _client.from('protocolos').select();
      if (tipo != null) {
        consulta = consulta.eq('tipo', tipo.valor);
      }
      final dados = await consulta.order('criado_em', ascending: false);
      return dados.map(Protocolo.fromMap).toList();
    }, 'Não foi possível carregar seus protocolos.');
  }

  Future<Protocolo> buscar(String id) {
    _exigirLogin();
    return executar(() async {
      final dado =
          await _client.from('protocolos').select().eq('id', id).single();
      return Protocolo.fromMap(dado);
    }, 'Não foi possível carregar o protocolo.');
  }

  /// Link temporário para exibir a imagem (o bucket é privado).
  /// Retorna null se o protocolo não tiver imagem.
  Future<String?> urlDaImagem(Protocolo protocolo, {int segundos = 3600}) {
    final caminho = protocolo.imagemPath;
    if (caminho == null) return Future.value(null);

    return executar(
      () => _client.storage.from(_bucket).createSignedUrl(caminho, segundos),
      'Não foi possível carregar a imagem.',
    );
  }
}