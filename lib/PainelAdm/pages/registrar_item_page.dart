import 'package:flutter/material.dart';
import '../theme.dart';

class RegistrarItemPage extends StatefulWidget {
  const RegistrarItemPage({super.key});

  @override
  State<RegistrarItemPage> createState() => _RegistrarItemPageState();
}

class _RegistrarItemPageState extends State<RegistrarItemPage> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  String _tipo = 'livro';
  String _estado = 'bom';

  static const _tipos = <String, String>{
    'livro': 'Livro',
    'eletronico': 'Eletrônico',
    'itens_gerais': 'Itens gerais',
    'sala': 'Sala',
  };

  static const _estados = <String, String>{
    'bom': 'Bom',
    'mediano': 'Mediano',
    'pessimo': 'Péssimo',
  };

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _registrar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item registrado (demonstração visual, sem persistência).'),
        backgroundColor: AdminTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registre um novo item no acervo da biblioteca.',
                style: TextStyle(color: AdminTheme.textMuted),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 760;
                  final form = _formCard();
                  final side = _sideCard();
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: form),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: side),
                      ],
                    );
                  }
                  return Column(children: [form, const SizedBox(height: 16), side]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.add_box_outlined, color: AdminTheme.primary),
                SizedBox(width: 8),
                Text('Dados do item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AdminTheme.text)),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do item',
                hintText: 'Ex.: Introdução a Algoritmos, Projetor Epson, Sala 204',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _tipos.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _tipo = v ?? _tipo),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _estado,
                    decoration: const InputDecoration(
                      labelText: 'Estado de conservação',
                      prefixIcon: Icon(Icons.fact_check_outlined),
                    ),
                    items: _estados.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _estado = v ?? _estado),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descricaoController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Detalhes sobre o item, edição, características, localização, etc.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            const Text('Imagem do item', style: TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.text)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seleção de imagem (demonstração visual).')),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AdminTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminTheme.border, style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 36, color: AdminTheme.primary),
                    SizedBox(height: 8),
                    Text('Clique para adicionar uma imagem', style: TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.text)),
                    SizedBox(height: 4),
                    Text('JPG, PNG ou WEBP · até 5 MB', style: TextStyle(fontSize: 12, color: AdminTheme.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _registrar,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Registrar item'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    _nomeController.clear();
                    _descricaoController.clear();
                    setState(() {
                      _tipo = 'livro';
                      _estado = 'bom';
                    });
                  },
                  child: const Text('Limpar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sideCard() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: AdminTheme.primary),
                    SizedBox(width: 8),
                    Text('Sobre o cadastro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                _tip('Itens cadastrados pela biblioteca ficam como acervo da universidade.'),
                _tip('Tipos disponíveis: livro, eletrônico, itens gerais e sala.'),
                _tip('O estado de conservação ajuda no controle e na identificação de itens com defeito.'),
                _tip('A disponibilidade e empréstimos serão gerenciados nas seções do painel.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pré-visualização rápida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AdminTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nomeController.text.isEmpty ? 'Nome do item' : _nomeController.text,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AdminTheme.text),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(_tipos[_tipo] ?? _tipo, AdminTheme.primary),
                          _chip('Estado: ${_estados[_estado]}', _estado == 'pessimo' ? AdminTheme.danger : AdminTheme.success),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _descricaoController.text.isEmpty ? 'A descrição do item aparecerá aqui.' : _descricaoController.text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: AdminTheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
