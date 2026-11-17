class Topico {
  const Topico({
    required this.id,
    required this.autorId,
    required this.titulo,
    required this.descricao,
    required this.tema,
    required this.criadoEm,
    this.totalComentarios = 0,
  });

  final String id;
  final String autorId;
  final String titulo;
  final String descricao;
  final String tema;
  final DateTime criadoEm;
  final int totalComentarios;

  factory Topico.fromMap(Map<String, dynamic> map) {
    // Quando a consulta usa "comentarios(count)", o Supabase devolve
    // [{count: N}] dentro da chave "comentarios".
    var total = 0;
    final contagem = map['comentarios'];
    if (contagem is List && contagem.isNotEmpty) {
      total = (contagem.first['count'] as num?)?.toInt() ?? 0;
    }

    return Topico(
      id: map['id'] as String,
      autorId: map['autor_id'] as String,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      tema: map['tema'] as String,
      criadoEm: DateTime.parse(map['criado_em'] as String).toLocal(),
      totalComentarios: total,
    );
  }
}