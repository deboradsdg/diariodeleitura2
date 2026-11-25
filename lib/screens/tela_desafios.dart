import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cadastro_desafio.dart';
import 'detalhe_desafio.dart';

class TelaDesafios extends StatefulWidget {
  const TelaDesafios({super.key});

  @override
  State<TelaDesafios> createState() => _TelaDesafiosState();
}

class _TelaDesafiosState extends State<TelaDesafios> {
  final _supabase = Supabase.instance.client;
  bool _carregando = true;
  List<String> _categorias = [];

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    setState(() => _carregando = true);
    try {
      final List<dynamic> resposta = await _supabase
          .from('desafio_leitura')
          .select('categoria')
          .order('categoria', ascending: true);

      final lista = resposta
          .map((item) => item['categoria'].toString())
          .toSet()
          .toList();

      if (!mounted) return;
      setState(() {
        _categorias = lista;
        _carregando = false;
      });
    } catch (e) {
      debugPrint("Erro ao buscar categorias: $e");
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Desafios de Leitura', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarCategorias,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _categorias.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum desafio encontrado no banco.\nCrie um no botão abaixo!',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.emoji_events_outlined),
                        ),
                        title: Text(
                          categoria,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalheDesafio(categoria: categoria),
                            ),
                          );
                          _carregarCategorias();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final criou = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroDesafio()),
          );
          if (criou == true) {
            _carregarCategorias();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Desafio'),
      ),
    );
  }
}