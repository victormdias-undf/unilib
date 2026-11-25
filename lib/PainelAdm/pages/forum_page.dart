import 'package:flutter/material.dart';
import '../theme.dart';

class _Comentario {
  final String autor;
  final String texto;
  final String data;
  const _Comentario(this.autor, this.texto, this.data);
}

class _Topico {
  final String nome;
  final String autor;
  final String data;
  final List<String> tags;
  final List<_Comentario> comentarios;
  const _Topico(this.nome, this.autor, this.data, this.tags, this.comentarios);
}

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  static const _topicos = <_Topico>[
    _Topico(
      'Sugestões para melhorar o acervo de tecnologia',
      'Ana Costa',
      '18/11/2026',
      ['Sugestões', 'Biblioteca', 'Tecnologia e Wi-Fi'],
      [
        _Comentario('Lucas Rocha', 'Seria ótimo ter mais livros atualizados sobre Flutter e arquitetura mobile.', '18/11/2026 10:10'),
        _Comentario('Maria Silva', 'Concordo! E também alguns exemplares sobre ciência de dados.', '18/11/2026 10:45'),
        _Comentario('João Pereira', 'Poderiam incluir e-readers para empréstimo também.', '18/11/2026 11:02'),
      ],
    ),
    _Topico(
      'Dúvida sobre horário de devolução',
      'Beatriz Lima',
      '17/11/2026',
      ['Dúvidas', 'Empréstimos'],
      [
        _Comentario('Pedro Alves', 'Acho que dá para devolver até o fechamento da biblioteca.', '17/11/2026 14:00'),
        _Comentario('Ana Costa', 'No app aparece a data limite, mas seria bom mostrar o horário também.', '17/11/2026 14:18'),
      ],
    ),
    _Topico(
      'Elogio ao atendimento do balcão',
      'Lucas Rocha',
      '16/11/2026',
      ['Elogios', 'Biblioteca'],
      [
        _Comentario('Maria Silva', 'Também tive uma ótima experiência essa semana!', '16/11/2026 09:30'),
      ],
    ),
    _Topico(
      'Reclamação: ruído nas salas de estudo',
      'João Pereira',
      '15/11/2026',
      ['Reclamações', 'Salas de Estudo', 'Infraestrutura'],
      [
        _Comentario('Beatriz Lima', 'Percebi isso principalmente à tarde.', '15/11/2026 15:10'),
        _Comentario('Carlos Nunes', 'Seria bom reforçar a sinalização de silêncio.', '15/11/2026 15:42'),
        _Comentario('Ana Costa', 'Algumas salas precisam de manutenção nas portas também.', '15/11/2026 16:05'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acompanhe os tópicos do fórum e o que os alunos estão comentando.',
            style: TextStyle(color: AdminTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _stat('Tópicos', '${_topicos.length}', Icons.forum_outlined, AdminTheme.primary),
              _stat('Comentários', '${_topicos.fold<int>(0, (p, e) => p + e.comentarios.length)}', Icons.chat_bubble_outline, const Color(0xFF00838F)),
              _stat('Tags em uso', '8', Icons.sell_outlined, AdminTheme.warning),
            ],
          ),
          const SizedBox(height: 16),
          ..._topicos.map((t) => _topicCard(context, t)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AdminTheme.border)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
        ],
      ),
    );
  }

  Widget _topicCard(BuildContext context, _Topico t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          leading: CircleAvatar(
            backgroundColor: AdminTheme.primaryLight,
            child: Text(t.autor.substring(0, 1), style: const TextStyle(color: AdminTheme.primary, fontWeight: FontWeight.w700)),
          ),
          title: Text(t.nome, style: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.text)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Por ${t.autor} · ${t.data} · ${t.comentarios.length} comentário(s)',
                    style: const TextStyle(fontSize: 12, color: AdminTheme.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: t.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AdminTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(tag, style: const TextStyle(color: AdminTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          children: [
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Comentários', style: TextStyle(color: AdminTheme.textMuted, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            const SizedBox(height: 8),
            ...t.comentarios.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminTheme.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Text(c.autor.substring(0, 1), style: const TextStyle(color: AdminTheme.primary, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(c.autor, style: const TextStyle(fontWeight: FontWeight.w700))),
                                Text(c.data, style: const TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(c.texto, style: const TextStyle(color: AdminTheme.text, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ação de moderação/visualização (demonstração visual).')),
                  );
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver tópico completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
