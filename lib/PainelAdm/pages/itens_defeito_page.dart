import 'package:flutter/material.dart';
import '../theme.dart';

class _ItemDefeito {
  final String nome;
  final String tipo;
  final String estado;
  final String origem;
  final String relato;
  final String atualizadoEm;
  final String severidade; // alta, media, baixa
  const _ItemDefeito(this.nome, this.tipo, this.estado, this.origem, this.relato, this.atualizadoEm, this.severidade);
}

class ItensDefeitoPage extends StatelessWidget {
  const ItensDefeitoPage({super.key});

  static const _itens = <_ItemDefeito>[
    _ItemDefeito('Projetor Epson X41', 'Eletrônico', 'Péssimo', 'Universidade',
        'Lâmpada queimada e imagem com manchas.', 'Hoje, 09:20', 'alta'),
    _ItemDefeito('Cabo HDMI 2m', 'Itens gerais', 'Péssimo', 'Acervo aluno',
        'Conector frouxo, sinal intermitente.', 'Ontem, 16:40', 'media'),
    _ItemDefeito('Cadeira de estudo A12', 'Itens gerais', 'Mediano', 'Universidade',
        'Apoio de braço solto.', '16/11/2026', 'media'),
    _ItemDefeito('Notebook Dell (patrimônio 334)', 'Eletrônico', 'Péssimo', 'Universidade',
        'Não liga; possível falha na bateria.', '15/11/2026', 'alta'),
    _ItemDefeito('Livro: Física II (capa danificada)', 'Livro', 'Mediano', 'Acervo aluno',
        'Páginas soltas e capa rasgada.', '14/11/2026', 'baixa'),
  ];

  Color _sevColor(String s) {
    switch (s) {
      case 'alta':
        return AdminTheme.danger;
      case 'media':
        return AdminTheme.warning;
      default:
        return const Color(0xFF1565C0);
    }
  }

  String _sevLabel(String s) {
    switch (s) {
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Média';
      default:
        return 'Baixa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visualize e acompanhe itens com defeito ou em mau estado de conservação.',
            style: TextStyle(color: AdminTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _summary('Total com defeito', '5', Icons.report_problem_outlined, AdminTheme.danger),
              _summary('Severidade alta', '2', Icons.priority_high, AdminTheme.danger),
              _summary('Severidade média', '2', Icons.remove_circle_outline, AdminTheme.warning),
              _summary('Severidade baixa', '1', Icons.info_outline, const Color(0xFF1565C0)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Itens sinalizados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.tune), label: const Text('Filtrar')),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('Exportar')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 900;
                      if (wide) {
                        return _tableView(context);
                      }
                      return Column(
                        children: _itens.map((e) => _itemCard(context, e)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableView(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.text),
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Origem')),
          DataColumn(label: Text('Severidade')),
          DataColumn(label: Text('Relato')),
          DataColumn(label: Text('Atualizado em')),
          DataColumn(label: Text('Ações')),
        ],
        rows: _itens.map((e) {
          return DataRow(cells: [
            DataCell(Text(e.nome, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(_badge(e.tipo, AdminTheme.primary)),
            DataCell(_badge(e.estado, e.estado == 'Péssimo' ? AdminTheme.danger : AdminTheme.warning)),
            DataCell(Text(e.origem)),
            DataCell(_badge(_sevLabel(e.severidade), _sevColor(e.severidade))),
            DataCell(SizedBox(width: 260, child: Text(e.relato, overflow: TextOverflow.ellipsis))),
            DataCell(Text(e.atualizadoEm)),
            DataCell(Row(
              children: [
                IconButton(
                  tooltip: 'Ver detalhes',
                  onPressed: () => _showDetails(context, e),
                  icon: const Icon(Icons.visibility_outlined, color: AdminTheme.primary),
                ),
                IconButton(
                  tooltip: 'Marcar como resolvido',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${e.nome}" marcado como resolvido (demonstração visual).')),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, color: AdminTheme.success),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _itemCard(BuildContext context, _ItemDefeito e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
        color: AdminTheme.surfaceAlt,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(e.nome, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
              _badge(_sevLabel(e.severidade), _sevColor(e.severidade)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _badge(e.tipo, AdminTheme.primary),
            _badge('Estado: ${e.estado}', e.estado == 'Péssimo' ? AdminTheme.danger : AdminTheme.warning),
            _badge(e.origem, AdminTheme.textMuted),
          ]),
          const SizedBox(height: 8),
          Text(e.relato, style: const TextStyle(color: AdminTheme.text)),
          const SizedBox(height: 6),
          Text('Atualizado em ${e.atualizadoEm}', style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(onPressed: () => _showDetails(context, e), icon: const Icon(Icons.visibility_outlined), label: const Text('Detalhes')),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${e.nome}" marcado como resolvido (demonstração visual).')),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Resolver'),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, _ItemDefeito e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(e.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${e.tipo}'),
            Text('Estado: ${e.estado}'),
            Text('Origem: ${e.origem}'),
            Text('Severidade: ${_sevLabel(e.severidade)}'),
            const SizedBox(height: 8),
            Text(e.relato),
            const SizedBox(height: 8),
            Text('Atualizado em: ${e.atualizadoEm}', style: const TextStyle(color: AdminTheme.textMuted)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
      ),
    );
  }

  Widget _summary(String label, String value, IconData icon, Color color) {
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

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
