import 'package:flutter/material.dart';
import '../theme.dart';

class _EmprestimoMock {
  final String item;
  final String tipo;
  final String aluno;
  final String dataEntrega;
  final bool atrasado;
  final String origem;
  const _EmprestimoMock(this.item, this.tipo, this.aluno, this.dataEntrega, this.atrasado, this.origem);
}

class DevolucoesPage extends StatefulWidget {
  const DevolucoesPage({super.key});

  @override
  State<DevolucoesPage> createState() => _DevolucoesPageState();
}

class _DevolucoesPageState extends State<DevolucoesPage> {
  final List<_EmprestimoMock> _itens = const [
    _EmprestimoMock('Cálculo Vol. 1', 'Livro', 'Maria Silva', '10/11/2026', true, 'Universidade'),
    _EmprestimoMock('Projetor Epson X41', 'Eletrônico', 'João Pereira', '12/11/2026', true, 'Universidade'),
    _EmprestimoMock('Sala de Estudo 204', 'Sala', 'Grupo PET', '18/11/2026', false, 'Universidade'),
    _EmprestimoMock('Kit Arduino Uno', 'Eletrônico', 'Ana Costa', '20/11/2026', false, 'Universidade'),
    _EmprestimoMock('Física Moderna', 'Livro', 'Lucas Rocha', '22/11/2026', false, 'Acervo aluno'),
    _EmprestimoMock('Cabo HDMI 2m', 'Itens gerais', 'Beatriz Lima', '25/11/2026', false, 'Acervo aluno'),
  ];

  final Set<int> _registrados = {};

  void _registrar(int index) {
    setState(() => _registrados.add(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Devolução de "${_itens[index].item}" registrada (demonstração visual).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendentes = _itens.where((e) => !_registrados.contains(_itens.indexOf(e))).length;
    final atrasados = _itens.where((e) => e.atrasado && !_registrados.contains(_itens.indexOf(e))).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acompanhe os itens emprestados e registre devoluções quando forem entregues.',
            style: TextStyle(color: AdminTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _miniStat('Pendentes', '$pendentes', Icons.hourglass_bottom, AdminTheme.primary),
              _miniStat('Atrasados', '$atrasados', Icons.warning_amber_rounded, AdminTheme.danger),
              _miniStat('Registradas hoje', '${_registrados.length}', Icons.check_circle_outline, AdminTheme.success),
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
                        child: Text('Itens emprestados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AdminTheme.text)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filtrar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.text),
                            dataTextStyle: const TextStyle(color: AdminTheme.text),
                            columns: const [
                              DataColumn(label: Text('Item')),
                              DataColumn(label: Text('Tipo')),
                              DataColumn(label: Text('Aluno / responsável')),
                              DataColumn(label: Text('Origem')),
                              DataColumn(label: Text('Data de entrega')),
                              DataColumn(label: Text('Situação')),
                              DataColumn(label: Text('Ação')),
                            ],
                            rows: List.generate(_itens.length, (i) {
                              final e = _itens[i];
                              final done = _registrados.contains(i);
                              return DataRow(
                                color: MaterialStateProperty.all(
                                  done ? AdminTheme.success.withOpacity(0.06) : (e.atrasado ? AdminTheme.danger.withOpacity(0.04) : null),
                                ),
                                cells: [
                                  DataCell(Text(e.item, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(_pill(e.tipo, AdminTheme.primary)),
                                  DataCell(Text(e.aluno)),
                                  DataCell(Text(e.origem)),
                                  DataCell(Text(e.dataEntrega)),
                                  DataCell(_statusPill(done, e.atrasado)),
                                  DataCell(
                                    ElevatedButton.icon(
                                      onPressed: done ? null : () => _registrar(i),
                                      icon: Icon(done ? Icons.check : Icons.assignment_return, size: 18),
                                      label: Text(done ? 'Devolvido' : 'Registrar devolução'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        backgroundColor: done ? AdminTheme.textMuted : AdminTheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
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

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
              Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _statusPill(bool done, bool atrasado) {
    if (done) return _pill('Devolvido', AdminTheme.success);
    if (atrasado) return _pill('Atrasado', AdminTheme.danger);
    return _pill('No prazo', const Color(0xFF1565C0));
  }
}
