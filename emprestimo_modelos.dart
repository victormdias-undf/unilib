import 'modelos.dart';

/// Estados calculados em tempo real a partir do prazo e da devolução.
class SituacoesEmprestimo {
  static const emDia = 'em_dia';
  static const atrasado = 'atrasado';
  static const devolvidoNoPrazo = 'devolvido_no_prazo';
  static const devolvidoAtrasado = 'devolvido_atrasado';
}

/// Um exemplar da Biblioteca Geral pode ter vários empréstimos no histórico,
/// mas no máximo um empréstimo ativo simultaneamente.
class EmprestimoLivro {
  final String id;
  final String livroId;
  final String usuarioId;
  final DateTime retiradoEm;
  final DateTime prazoDevolucao;
  final DateTime? devolvidoEm;
  final int renovacoes;

  const EmprestimoLivro({
    required this.id,
    required this.livroId,
    required this.usuarioId,
    required this.retiradoEm,
    required this.prazoDevolucao,
    this.devolvidoEm,
    this.renovacoes = 0,
  });

  bool get ativo => devolvidoEm == null;

  EmprestimoLivro copiarCom({
    DateTime? prazoDevolucao,
    DateTime? devolvidoEm,
    int? renovacoes,
  }) => EmprestimoLivro(
        id: id,
        livroId: livroId,
        usuarioId: usuarioId,
        retiradoEm: retiradoEm,
        prazoDevolucao: prazoDevolucao ?? this.prazoDevolucao,
        devolvidoEm: devolvidoEm ?? this.devolvidoEm,
        renovacoes: renovacoes ?? this.renovacoes,
      );

  String situacaoEm(DateTime referencia) {
    final dataComparacao = devolvidoEm ?? referencia.toUtc();
    if (devolvidoEm == null) {
      return dataComparacao.isAfter(prazoDevolucao)
          ? SituacoesEmprestimo.atrasado : SituacoesEmprestimo.emDia;
    }
    return dataComparacao.isAfter(prazoDevolucao)
        ? SituacoesEmprestimo.devolvidoAtrasado : SituacoesEmprestimo.devolvidoNoPrazo;
  }

  /// Qualquer fração de um dia de atraso conta como um dia.
  int diasAtrasoEm(DateTime referencia) {
    final diferenca = (devolvidoEm ?? referencia.toUtc()).difference(prazoDevolucao);
    if (diferenca <= Duration.zero) return 0;
    return (diferenca.inMicroseconds / Duration.microsecondsPerDay).ceil();
  }

  Map<String, Object?> toJson({DateTime? referencia}) {
    final agora = (referencia ?? DateTime.now()).toUtc();
    final tempoRestante = prazoDevolucao.difference(agora);
    final diasRestantes = ativo
        ? (tempoRestante <= Duration.zero
            ? 0 : (tempoRestante.inMicroseconds / Duration.microsecondsPerDay).ceil())
        : null;
    return {
      'id': id,
      'livroId': livroId,
      'usuarioId': usuarioId,
      'retiradoEm': retiradoEm.toUtc().toIso8601String(),
      'prazoDevolucao': prazoDevolucao.toUtc().toIso8601String(),
      'devolvidoEm': devolvidoEm?.toUtc().toIso8601String(),
      'renovacoes': renovacoes,
      'ativo': ativo,
      'situacao': situacaoEm(agora),
      'diasAtraso': diasAtrasoEm(agora),
      'diasRestantes': diasRestantes,
      'devolvidoNoPrazo': devolvidoEm == null
          ? null : !devolvidoEm!.isAfter(prazoDevolucao),
    };
  }
}

/// Paginação de empréstimos compatível com a estrutura de listagem da UniLib.
class PaginaEmprestimos {
  final List<EmprestimoLivro> emprestimos;
  final int total;
  final int pagina;
  final int limite;
  final DateTime referencia;

  const PaginaEmprestimos({
    required this.emprestimos,
    required this.total,
    required this.pagina,
    required this.limite,
    required this.referencia,
  });

  Map<String, Object?> toJson() => {
        'total': total,
        'pagina': pagina,
        'limite': limite,
        'totalPaginas': (total / limite).ceil(),
        'emprestimos': emprestimos.map((e) => e.toJson(referencia: referencia)).toList(),
      };
}

/// Configuração ilustrativa: não representa regulamento oficial da instituição.
class PoliticaEmprestimos {
  final int diasPrazo;
  final int diasRenovacao;
  final int maxRenovacoes;

  const PoliticaEmprestimos({
    this.diasPrazo = 14,
    this.diasRenovacao = 7,
    this.maxRenovacoes = 1,
  });

  void validar() {
    if (diasPrazo < 1 || diasRenovacao < 1 || maxRenovacoes < 0) {
      throw const ErroApi(500, 'Configuração de empréstimos inválida.');
    }
  }
}
