import 'package:flutter/material.dart';
import '../models/desafio_item.dart';
import '../models/livro.dart';
import '../services/data_access_object.dart';
import 'cadastro_livro.dart';
import 'detalhes_livro.dart';

class DetalheDesafio extends StatefulWidget {
  final DesafioItem desafio;

  const DetalheDesafio({super.key, required this.desafio});

  @override
  State<DetalheDesafio> createState() => _DetalheDesafioState();
}

class _DetalheDesafioState extends State<DetalheDesafio> {
  bool _carregando = true;
  List<Livro> _livrosCadastrados = [];
  // Guarda o vínculo em memória da meta (ex: "São Paulo (SP)" -> Livro)
  final Map<String, Livro?> _vinculos = {};

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  Future<void> _carregarLivros() async {
    setState(() => _carregando = true);
    final livros = await DataAccessObject.obterLivros();

    if (!mounted) return;

    setState(() {
      _livrosCadastrados = livros;
      _autovinculaLivrosExistentes();
      _carregando = false;
    });
  }

  // Busca se algum livro salvo no Supabase cita o nome da meta
  void _autovinculaLivrosExistentes() {
    for (var meta in widget.desafio.metas) {
      if (_vinculos[meta] != null) continue;

      final termoLimpo = meta.split('(').first.trim().toLowerCase();

      final Livro? correspondente = _livrosCadastrados.cast<Livro?>().firstWhere(
        (livro) {
          if (livro == null) return false;
          final gen = livro.genero.toLowerCase();
          final des = livro.destaque.toLowerCase();
          final com = livro.comentario.toLowerCase();
          final col = livro.nomeColecao.toLowerCase();

          return gen.contains(termoLimpo) ||
              des.contains(termoLimpo) ||
              com.contains(termoLimpo) ||
              col.contains(termoLimpo);
        },
        orElse: () => null,
      );

      if (correspondente != null) {
        _vinculos[meta] = correspondente;
      }
    }
  }

  // Modal para escolher qual livro do banco preenche este desafio
  void _vincularLivro(String meta) {
    if (_livrosCadastrados.isEmpty) {
      _irParaCadastro();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.65,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Vincular livro a: $meta',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: _livrosCadastrados.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final livro = _livrosCadastrados[index];
                    return ListTile(
                      dense: true,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: livro.urlCapa.isNotEmpty
                            ? Image.network(livro.urlCapa, width: 30, height: 45, fit: BoxFit.cover)
                            : const Icon(Icons.book, size: 30),
                      ),
                      title: Text(livro.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(livro.autor, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        setState(() {
                          _vinculos[meta] = livro;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _irParaCadastro();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Livro não cadastrado? Adicionar novo'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _irParaCadastro() async {
    final adicionou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroLivro()),
    );
    if (adicionou == true) {
      _carregarLivros();
    }
  }

  @override
  Widget build(BuildContext context) {
    final metasOrdenadas = List<String>.from(widget.desafio.metas)..sort();
    final concluidos = metasOrdenadas.where((m) => _vinculos[m] != null).length;
    final total = metasOrdenadas.length;
    final double progresso = total > 0 ? (concluidos / total) : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.desafio.titulo, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar novo livro',
            onPressed: _irParaCadastro,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de progresso do desafio
                Container(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progresso: $concluidos de $total lidos',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${(progresso * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progresso, minHeight: 8),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Lista alfabética de metas
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    itemCount: metasOrdenadas.length,
                    itemBuilder: (context, index) {
                      final meta = metasOrdenadas[index];
                      final livroVinculado = _vinculos[meta];
                      final bool cumprido = livroVinculado != null;

                      return Card(
                        elevation: 1.5,
                        margin: const EdgeInsets.only(bottom: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            cumprido ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: cumprido ? Colors.green : Colors.grey,
                            size: 22,
                          ),
                          title: Text(
                            meta,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              decoration: cumprido ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: cumprido
                              ? Text(
                                  'Livro: ${livroVinculado.titulo} (${livroVinculado.autor})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: Colors.teal),
                                )
                              : const Text('Nenhum livro vinculado ainda',
                                  style: TextStyle(fontSize: 11, color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (cumprido)
                                IconButton(
                                  icon: const Icon(Icons.menu_book, size: 18),
                                  tooltip: 'Ver detalhes do livro',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalhesLivro(livro: livroVinculado),
                                      ),
                                    );
                                  },
                                ),
                              IconButton(
                                icon: Icon(cumprido ? Icons.swap_horiz : Icons.link, size: 20),
                                tooltip: cumprido ? 'Alterar livro' : 'Vincular livro do diário',
                                onPressed: () => _vincularLivro(meta),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irParaCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar Livro'),
      ),
    );
  }
}