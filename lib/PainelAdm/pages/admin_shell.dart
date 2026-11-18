import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_page.dart';
import 'registrar_item_page.dart';
import 'devolucoes_page.dart';
import 'itens_defeito_page.dart';
import 'protocolos_page.dart';
import 'forum_page.dart';
import 'acervo_alunos_page.dart';
import 'login_admin_page.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final Widget page;
  final String? subtitle;
  const _NavItem(this.label, this.icon, this.page, {this.subtitle});
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selected = 0;

  late final List<_NavItem> _items = const [
    _NavItem('Visão geral', Icons.dashboard_outlined, DashboardPage(),
        subtitle: 'Resumo do painel'),
    _NavItem('Registrar item', Icons.add_box_outlined, RegistrarItemPage(),
        subtitle: 'Novo item no acervo'),
    _NavItem('Devoluções', Icons.assignment_return_outlined, DevolucoesPage(),
        subtitle: 'Registrar devolução'),
    _NavItem('Itens com defeito', Icons.report_problem_outlined, ItensDefeitoPage(),
        subtitle: 'Acompanhar avarias'),
    _NavItem('Protocolos', Icons.description_outlined, ProtocolosPage(),
        subtitle: 'Mensagens dos alunos'),
    _NavItem('Fórum', Icons.forum_outlined, ForumPage(),
        subtitle: 'Tópicos e comentários'),
    _NavItem('Acervo dos alunos', Icons.groups_outlined, AcervoAlunosPage(),
        subtitle: 'Itens disponibilizados'),
  ];

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginAdminPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 900;

    return Scaffold(
      body: Row(
        children: [
          if (!isCompact) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isCompact),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      key: ValueKey(_selected),
                      color: AdminTheme.background,
                      alignment: Alignment.topLeft,
                      child: _items[_selected].page,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isCompact ? Drawer(child: SafeArea(child: _buildSidebarContent(inDrawer: true))) : null,
    );
  }

  Widget _buildTopBar(bool isCompact) {
    final item = _items[_selected];
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        children: [
          if (isCompact)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AdminTheme.primary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          if (isCompact) const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AdminTheme.text,
                  ),
                ),
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: const TextStyle(fontSize: 12, color: AdminTheme.textMuted),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AdminTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AdminTheme.border),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AdminTheme.primaryLight,
                  child: Icon(Icons.account_balance, size: 16, color: AdminTheme.primary),
                ),
                SizedBox(width: 8),
                Text(
                  'Biblioteca',
                  style: TextStyle(
                    color: AdminTheme.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 272,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AdminTheme.border)),
      ),
      child: SafeArea(child: _buildSidebarContent(inDrawer: false)),
    );
  }

  Widget _buildSidebarContent({required bool inDrawer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UniLib',
                style: TextStyle(
                  fontFamily: AdminTheme.titleFont,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminTheme.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Painel administrativo',
                  style: TextStyle(
                    color: AdminTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final selected = index == _selected;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _selected = index);
                    if (inDrawer) Navigator.of(context).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: selected ? AdminTheme.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: selected ? AdminTheme.primary : AdminTheme.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: selected ? AdminTheme.primary : AdminTheme.text,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ),
      ],
    );
  }
}
