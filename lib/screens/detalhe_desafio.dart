import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/desafio_item.dart';
import '../models/livro.dart';
import '../services/data_access_object.dart';
import 'cadastro_livro.dart';
import 'detalhes_livro.dart';

class DetalheDesafio extends StatefulWidget {
  final String categoria;

  const DetalheDesafio({super.key, required this.categoria});

  @override
  State<DetalheDesafio> createState() => _DetalheDesafioState();
}

class _DetalheDesafioState extends State<DetalheDesafio> {
  final _supabase = Supabase.instance.client;
  bool _carregando = true;

  List<DesafioItem> _metas = [];
  List<Livro> _livrosCadastrados = [];
  final Map<String, Livro?> _vinculos = {}; // desafio_id -> Livro

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      // 1. Busca os desafios da categoria ordenados por título
      final List<dynamic> itensData = await _supabase
          .from('desafio_leitura')
          .select()
          .eq('categoria', widget.categoria)
          .order('titulo', ascending: true);

      final metasCarregadas = itensData.map((e) => DesafioItem.fromMap(e as Map<String, dynamic>)).toList();

      // 2. Busca livros do diário
      final livros = await DataAccessObject.obterLivros();

      // 3. Busca progressos já salvos
      final List<dynamic> progressos = await _supabase
          .from('progresso_desafio')
          .select();

      final Map<String, Livro?> mapaRecuperado = {};

      for (var p in progressos) {
        final dId = p['desafio_id']?.toString() ?? '';
        final idLivro = p['id_livro'] != null ? int.tryParse(p['id_livro'].toString()) : null;
        final titulo = p['titulo_livro']?.toString() ?? '';

        Livro? correspondente;
        if (idLivro != null) {
          correspondente = livros.cast<Livro?>().firstWhere(
            (l) => l?.id == idLivro,
            orElse: () => null,
          );
        }

        correspondente ??= livros.cast<Livro?>().firstWhere(
          (l) => l?.titulo.trim().toLowerCase() == titulo.trim().toLowerCase(),
          orElse: () => null,
        );

        correspondente ??= Livro(
          id: idLivro,
          titulo: titulo,
          autor: p['autor_livro']?.toString() ?? '',
          urlCapa: p['capa_url']?.toString() ?? '',
          sinopse: '',
          genero: '',
          nota: 5.0,
          destaque: '',
          ehColecao: false,
          nomeColecao: '',
          comentario: '',
        );

        mapaRecuperado[dId] = correspondente;
      }

      if (!mounted) return;
      setState(() {
        _metas = metasCarregadas;
        _livrosCadastrados = livros;
        _vinculos.clear();
        _vinculos.addAll(mapaRecuperado);
        _carregando = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  Future<void> _salvarNoSupabase(String desafioId, Livro livro) async {
    try {
      await _supabase.from('progresso_desafio').upsert({
        'desafio_id': desafioId,
        'id_livro': livro.id,
        'titulo_livro': livro.titulo,
        'autor_livro': livro.autor,
        'capa_url': livro.urlCapa,
      }, onConflict: 'desafio_id');

      setState(() {
        _vinculos[desafioId] = livro;
      });
    } catch (e) {
      debugPrint("Erro ao salvar progresso: $e");
    }
  }

  Future<void> _desvincularLivro(String desafioId) async {
    try {
      await _supabase.from('progresso_desafio').delete().eq('desafio_id', desafioId);
      setState(() {
        _vinculos.remove(desafioId);
      });
    } catch (e) {
      debugPrint("Erro ao remover vínculo: $e");
    }
  }

  void _vincularLivro(DesafioItem item) {
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
                  'Vincular livro a: ${item.titulo}',
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
                        Navigator.pop(ctx);
                        _salvarNoSupabase(item.id, livro);
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
      _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    final concluidos = _metas.where((m) => _vinculos[m.id] != null).length;
    final total = _metas.length;
    final double progresso = total > 0 ? (concluidos / total) : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.categoria, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Cadastrar novo livro no diário',
            onPressed: _irParaCadastro,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    itemCount: _metas.length,
                    itemBuilder: (context, index) {
                      final item = _metas[index];
                      final livroVinculado = _vinculos[item.id];
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
                            item.titulo,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              decoration: cumprido ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.descricao.isNotEmpty)
                                Text(item.descricao,
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              if (cumprido)
                                Text(
                                  'Lido: ${livroVinculado.titulo} (${livroVinculado.autor})',
                                  style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (cumprido) ...[
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                                  tooltip: 'Desvincular livro',
                                  onPressed: () => _desvincularLivro(item.id),
                                ),
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
                              ],
                              IconButton(
                                icon: Icon(cumprido ? Icons.swap_horiz : Icons.link, size: 20),
                                tooltip: cumprido ? 'Trocar livro' : 'Vincular livro do diário',
                                onPressed: () => _vincularLivro(item),
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