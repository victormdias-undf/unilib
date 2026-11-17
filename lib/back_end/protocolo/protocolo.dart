enum TipoProtocolo {
  reclamacao('reclamacao'),
  elogio('elogio');

  const TipoProtocolo(this.valor);
  final String valor;

  static TipoProtocolo deValor(String valor) =>
      TipoProtocolo.values.firstWhere((t) => t.valor == valor);
}

enum StatusProtocolo {
  aberto('aberto'),
  emAnalise('em_analise'),
  resolvido('resolvido');

  const StatusProtocolo(this.valor);
  final String valor;

  static StatusProtocolo deValor(String valor) =>
      StatusProtocolo.values.firstWhere((s) => s.valor == valor);
}

class Protocolo {
  const Protocolo({
    required this.id,
    required this.autorId,
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.criadoEm,
    this.imagemPath,
  });

  final String id;
  final String autorId;
  final TipoProtocolo tipo;
  final String titulo;
  final String descricao;
  final StatusProtocolo status;
  final DateTime criadoEm;

  /// Caminho da imagem no Storage (opcional). Use
  /// `ProtocoloService.urlDaImagem` para obter um link temporário.
  final String? imagemPath;

  bool get temImagem => imagemPath != null;

  factory Protocolo.fromMap(Map<String, dynamic> map) {
    return Protocolo(
      id: map['id'] as String,
      autorId: map['autor_id'] as String,
      tipo: TipoProtocolo.deValor(map['tipo'] as String),
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      status: StatusProtocolo.deValor(map['status'] as String),
      criadoEm: DateTime.parse(map['criado_em'] as String).toLocal(),
      imagemPath: map['imagem_path'] as String?,
    );
  }
}
