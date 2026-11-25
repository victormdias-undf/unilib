import 'package:flutter/material.dart';
import '../theme.dart';

class _Protocolo {
  final String titulo;
  final String mensagem;
  final String aluno;
  final String data;
  final bool novo;
  const _Protocolo(this.titulo, this.mensagem, this.aluno, this.data, this.novo);
}

class ProtocolosPage extends StatefulWidget {
  const ProtocolosPage({super.key});

  @override
  State<ProtocolosPage> createState() => _ProtocolosPageState();
}

class _ProtocolosPageState extends State<ProtocolosPage> {
  int _selected = 0;

  static const _protocolos = <_Protocolo>[
    _Protocolo(
      'Solicitação de renovação de empréstimo',
      'Olá, gostaria de solicitar a renovação do livro "Cálculo Vol. 1" por mais 7 dias, pois ainda estou utilizando para os estudos da prova. É possível?',
      'Maria Silva',
      '18/11/2026 09:12',
      true,
    ),
    _Protocolo(
      'Problema no ar-condicionado da sala 204',
      'A sala de estudo 204 está com o ar-condicionado sem funcionar desde ontem à tarde, dificultando o uso do espaço.',
      'João Pereira',
      '18/11/2026 08:40',
      true,
    ),
    _Protocolo(
      'Dúvida sobre reserva de salas',
      'Qual é o procedimento correto para reservar a sala multimídia para apresentação de TCC? Não encontrei essa opção no app.',
      'Ana Costa',
      '17/11/2026 16:05',
      false,
    ),
    _Protocolo(
      'Sugestão de novos livros de programação',
      'Seria interessante adicionar títulos mais recentes sobre Flutter e engenharia de software ao acervo da biblioteca.',
      'Lucas Rocha',
      '17/11/2026 11:30',
      false,
    ),
    _Protocolo(
      'Relato de barulho no setor de estudos',
      'Tenho percebido barulho frequente no setor silencioso no período da tarde. Poderiam reforçar a sinalização?',
      'Beatriz Lima',
      '16/11/2026 14:22',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consulte os protocolos (mensagens) enviados pelos alunos para a biblioteca.',
            style: TextStyle(color: AdminTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;
                if (!wide) {
                  return _listOnly();
                }
                return Row(
                  children: [
                    SizedBox(width: 380, child: _listPane()),
                    const SizedBox(width: 16),
                    Expanded(child: _detailPane(_protocolos[_selected])),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _listOnly() {
    return ListView.separated(
      itemCount: _protocolos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final p = _protocolos[i];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              backgroundColor: AdminTheme.primaryLight,
              child: Text(p.aluno.substring(0, 1), style: const TextStyle(color: AdminTheme.primary, fontWeight: FontWeight.w700)),
            ),
            title: Row(
              children: [
                Expanded(child: Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.w700))),
                if (p.novo) _badge('Novo', AdminTheme.primary),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p.aluno} · ${p.data}', style: const TextStyle(fontSize: 12, color: AdminTheme.textMuted)),
                  const SizedBox(height: 4),
                  Text(p.mensagem, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
              builder: (_) => Padding(padding: const EdgeInsets.all(20), child: _detailContent(p)),
            ),
          ),
        );
      },
    );
  }

  Widget _listPane() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Expanded(child: Text('Caixa de protocolos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                _badge('${_protocolos.where((e) => e.novo).length} novos', AdminTheme.primary),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _protocolos.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = _protocolos[i];
                final selected = i == _selected;
                return InkWell(
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    color: selected ? AdminTheme.primaryLight.withOpacity(0.35) : null,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w600, color: AdminTheme.text),
                              ),
                            ),
                            if (p.novo) _badge('Novo', AdminTheme.primary),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(p.aluno, style: const TextStyle(fontSize: 12, color: AdminTheme.textMuted)),
                        const SizedBox(height: 2),
                        Text(p.mensagem, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AdminTheme.text)),
                        const SizedBox(height: 4),
                        Text(p.data, style: const TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPane(_Protocolo p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _detailContent(p),
      ),
    );
  }

  Widget _detailContent(_Protocolo p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AdminTheme.primaryLight,
              child: Text(p.aluno.substring(0, 1), style: const TextStyle(color: AdminTheme.primary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.aluno, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(p.data, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            if (p.novo) _badge('Novo', AdminTheme.primary),
          ],
        ),
        const SizedBox(height: 18),
        Text(p.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AdminTheme.text)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AdminTheme.surfaceAlt, borderRadius: BorderRadius.circular(12)),
          child: Text(p.mensagem, style: const TextStyle(fontSize: 15, height: 1.5, color: AdminTheme.text)),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.reply_outlined),
              label: const Text('Responder (visual)'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mark_email_read_outlined),
              label: const Text('Marcar como lido'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.archive_outlined),
              label: const Text('Arquivar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
