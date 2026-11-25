import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastroDesafio extends StatefulWidget {
  const CadastroDesafio({super.key});

  @override
  State<CadastroDesafio> createState() => _CadastroDesafioState();
}

class _CadastroDesafioState extends State<CadastroDesafio> {
  final _supabase = Supabase.instance.client;
  final _categoriaController = TextEditingController();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _categoriaController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final cat = _categoriaController.text.trim();
    final tit = _tituloController.text.trim();
    final desc = _descricaoController.text.trim();

    if (cat.isEmpty || tit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha a Categoria e o Título da Meta.')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      await _supabase.from('desafio_leitura').insert({
        'categoria': cat,
        'titulo': tit,
        'descricao': desc,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar no Supabase: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Criar Desafio / Meta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _categoriaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Categoria do Desafio',
                hintText: 'Ex.: Desafio 2027, Estados Brasileiros, Clássicos...',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Título da Meta',
                hintText: 'Ex.: São Paulo (SP), Poesia, Livro com +400 páginas',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descricaoController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Descrição / Regras',
                hintText: 'Ex.: Livro ambientado ou de autor nascido no local.',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: _salvando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(_salvando ? 'Salvando...' : 'Salvar no Banco'),
            ),
          ],
        ),
      ),
    );
  }
}