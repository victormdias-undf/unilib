import 'package:flutter/material.dart';
import '../theme.dart';

class _ItemAluno {
  final String nome;
  final String tipo;
  final String aluno;
  final String estado;
  final bool emprestado;
  final String descricao;
  final String criadoEm;
  const _ItemAluno(this.nome, this.tipo, this.aluno, this.estado, this.emprestado, this.descricao, this.criadoEm);
}

class AcervoAlunosPage extends StatefulWidget {
  const AcervoAlunosPage({super.key});

  @override
  State<AcervoAlunosPage> createState() => _AcervoAlunosPageState();
}

class _AcervoAlunosPageState extends State<AcervoAlunosPage> {
  String _filtroTipo = 'todos';

  static const _itens = <_ItemAluno>[
    _ItemAluno('Calculadora Científica Casio fx-82', 'Eletrônico', 'Maria Silva', 'Bom', false,
        'Calculadora em ótimo estado, com capa protetora.', '18/11/2026'),
    _ItemAluno('Livro: Estruturas de Dados em C', 'Livro', 'João Pereira', 'Bom', true,
        'Edição recente, sem marcações.', '17/11/2026'),
    _ItemAluno('Cabo HDMI 2m', 'Itens gerais', 'Beatriz Lima', 'Péssimo', false,
        'Cabo com conector frouxo, sinal intermitente.', '17/11/2026'),
    _ItemAluno('Física Moderna', 'Livro', 'Lucas Rocha', 'Mediano', true,
        'Algumas anotações a lápis nas margens.', '16/11/2026'),
    _ItemAluno('Kit Arduino Uno', 'Eletrônico', 'Ana Costa', 'Bom', false,
        'Kit completo com cabos e protoboard.', '15/11/2026'),
    _ItemAluno('Adaptador USB-C para HDMI', 'Itens gerais', 'Pedro Alves', 'Bom', false,
        'Funciona com notebooks e tablets.', '14/11/2026'),
  ];

  List<_ItemAluno> get _filtrados {
    if (_filtroTipo == 'todos') return _itens;
    final map = {
      'livro': 'Livro',
      'eletronico': 'Eletrônico',
      'itens_gerais': 'Itens gerais',
    };
    return _itens.where((e) => e.tipo == map[_filtroTipo]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final disponiveis = _itens.where((e) => !e.emprestado).length;
    final emprestados = _itens.where((e) => e.emprestado).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acompanhe os itens que os alunos estão disponibilizando no acervo compartilhado.',
            style: TextStyle(color: AdminTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _stat('Itens dos alunos', '${_itens.length}', Icons.groups_outlined, AdminTheme.primary),
              _stat('Disponíveis', '$disponiveis', Icons.check_circle_outline, AdminTheme.success),
              _stat('Emprestados', '$emprestados', Icons.swap_horiz, const Color(0xFF1565C0)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Itens no acervo dos alunos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      _filtroChip('todos', 'Todos'),
                      _filtroChip('livro', 'Livros'),
                      _filtroChip('eletronico', 'Eletrônicos'),
                      _filtroChip('itens_gerais', 'Itens gerais'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 950;
                      if (wide) return _table();
                      return Column(children: _filtrados.map(_card).toList());
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

  Widget _filtroChip(String value, String label) {
    final selected = _filtroTipo == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filtroTipo = value),
      selectedColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(
        color: selected ? AdminTheme.primary : AdminTheme.text,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: const BorderSide(color: AdminTheme.border),
    );
  }

  Widget _table() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.text),
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Disponibilizado por')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Disponibilidade')),
          DataColumn(label: Text('Cadastrado em')),
          DataColumn(label: Text('Detalhes')),
        ],
        rows: _filtrados.map((e) {
          return DataRow(cells: [
            DataCell(SizedBox(
              width: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(e.descricao, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AdminTheme.textMuted)),
                ],
              ),
            )),
            DataCell(_badge(e.tipo, AdminTheme.primary)),
            DataCell(Row(children: [
              CircleAvatar(radius: 12, backgroundColor: AdminTheme.primaryLight, child: Text(e.aluno.substring(0, 1), style: const TextStyle(fontSize: 11, color: AdminTheme.primary, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Text(e.aluno),
            ])),
            DataCell(_badge(e.estado, e.estado == 'Péssimo' ? AdminTheme.danger : (e.estado == 'Mediano' ? AdminTheme.warning : AdminTheme.success))),
            DataCell(_badge(e.emprestado ? 'Emprestado' : 'Disponível', e.emprestado ? const Color(0xFF1565C0) : AdminTheme.success)),
            DataCell(Text(e.criadoEm)),
            DataCell(IconButton(
              icon: const Icon(Icons.visibility_outlined, color: AdminTheme.primary),
              onPressed: () => _showDetails(e),
              tooltip: 'Ver detalhes',
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _card(_ItemAluno e) {
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
              _badge(e.emprestado ? 'Emprestado' : 'Disponível', e.emprestado ? const Color(0xFF1565C0) : AdminTheme.success),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _badge(e.tipo, AdminTheme.primary),
            _badge('Estado: ${e.estado}', e.estado == 'Péssimo' ? AdminTheme.danger : (e.estado == 'Mediano' ? AdminTheme.warning : AdminTheme.success)),
          ]),
          const SizedBox(height: 8),
          Text('Disponibilizado por: ${e.aluno}', style: const TextStyle(color: AdminTheme.text, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(e.descricao, style: const TextStyle(color: AdminTheme.textMuted)),
          const SizedBox(height: 4),
          Text('Cadastrado em ${e.criadoEm}', style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: () => _showDetails(e), icon: const Icon(Icons.visibility_outlined), label: const Text('Ver detalhes')),
        ],
      ),
    );
  }

  void _showDetails(_ItemAluno e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(e.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${e.tipo}'),
            Text('Aluno: ${e.aluno}'),
            Text('Estado: ${e.estado}'),
            Text('Disponibilidade: ${e.emprestado ? "Emprestado" : "Disponível"}'),
            Text('Cadastrado em: ${e.criadoEm}'),
            const SizedBox(height: 8),
            Text(e.descricao),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
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

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
