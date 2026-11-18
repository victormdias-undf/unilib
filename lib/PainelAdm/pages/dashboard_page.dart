import 'package:flutter/material.dart';
import '../theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hero(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 1000;
              final crossAxisCount = wide ? 4 : (constraints.maxWidth > 650 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: wide ? 1.9 : 2.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _StatCard('Itens no acervo', '248', Icons.inventory_2_outlined, AdminTheme.primary,
                      subtitle: 'Universidade + alunos'),
                  _StatCard('Empréstimos ativos', '36', Icons.swap_horiz, Color(0xFF1565C0),
                      subtitle: 'Itens com alunos'),
                  _StatCard('Devoluções pendentes', '7', Icons.assignment_return_outlined, AdminTheme.warning,
                      subtitle: '2 com prazo vencido'),
                  _StatCard('Itens com defeito', '5', Icons.report_problem_outlined, AdminTheme.danger,
                      subtitle: 'Necessitam atenção'),
                  _StatCard('Protocolos recebidos', '12', Icons.description_outlined, Color(0xFF6A1B9A),
                      subtitle: '4 novos hoje'),
                  _StatCard('Tópicos no fórum', '18', Icons.forum_outlined, Color(0xFF00838F),
                      subtitle: 'Atividade recente'),
                  _StatCard('Acervo dos alunos', '41', Icons.groups_outlined, AdminTheme.success,
                      subtitle: 'Itens disponibilizados'),
                  _StatCard('Alunos cadastrados', '320', Icons.school_outlined, AdminTheme.textMuted,
                      subtitle: 'Base ativa'),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _recentActivity()),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: _quickAlerts()),
                  ],
                );
              }
              return Column(
                children: [
                  _recentActivity(),
                  const SizedBox(height: 14),
                  _quickAlerts(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AdminTheme.primary, Color(0xFF7C68B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vinda, Biblioteca',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Gerencie o acervo, empréstimos, protocolos e a comunidade em um só lugar.',
                style: TextStyle(color: Color(0xFFEDE7FF), fontSize: 14),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Visão do dia · aparência demonstrativa',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivity() {
    final items = const [
      ('Protocolo recebido: "Solicitação de renovação"', 'Há 10 min · Maria Silva', Icons.description_outlined),
      ('Novo item no acervo dos alunos', 'Há 35 min · Calculadora científica', Icons.groups_outlined),
      ('Comentário em "Sugestões para a biblioteca"', 'Há 1 h · Fórum', Icons.forum_outlined),
      ('Devolução registrada: "Cálculo Vol. 1"', 'Há 2 h · Empréstimos', Icons.assignment_return_outlined),
      ('Item sinalizado com defeito: "Projetor Epson"', 'Ontem · Manutenção', Icons.report_problem_outlined),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Atividades recentes', icon: Icons.history),
            const SizedBox(height: 12),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AdminTheme.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(e.$3, color: AdminTheme.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.text)),
                            const SizedBox(height: 2),
                            Text(e.$2, style: const TextStyle(fontSize: 12, color: AdminTheme.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _quickAlerts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Atenção rápida', icon: Icons.notifications_active_outlined),
            const SizedBox(height: 12),
            _alertTile('2 empréstimos com prazo vencido', 'Ver devoluções', AdminTheme.danger),
            _alertTile('5 itens marcados com defeito', 'Revisar itens', AdminTheme.warning),
            _alertTile('4 protocolos ainda não respondidos', 'Abrir protocolos', AdminTheme.primary),
            _alertTile('3 novos itens no acervo dos alunos', 'Conferir acervo', AdminTheme.success),
          ],
        ),
      ),
    );
  }

  Widget _alertTile(String title, String action, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.text, fontSize: 13)),
                const SizedBox(height: 2),
                Text(action, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AdminTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AdminTheme.text)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  const _StatCard(this.label, this.value, this.icon, this.color, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
