import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/data_access_object.dart';
import 'detalhes_livro.dart';

class ListaColecoes extends StatefulWidget {
  const ListaColecoes({super.key});

  @override
  State<ListaColecoes> createState() => _ListaColecoesState();
}

class _ListaColecoesState extends State<ListaColecoes> {
  bool _carregando = true;
  Map<String, List<Livro>> _colecoes = {};
  Map<String, List<Livro>> _generos = {};

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
    });

    final todosOsLivros = await DataAccessObject.obterLivros();

    final Map<String, List<Livro>> mapaColecoes = {};
    final Map<String, List<Livro>> mapaGeneros = {};

    for (var livro in todosOsLivros) {
      // Coleções
      if (livro.ehColecao && livro.nomeColecao.trim().isNotEmpty) {
        final col = livro.nomeColecao.trim();
        if (!mapaColecoes.containsKey(col)) {
          mapaColecoes[col] = [];
        }
        mapaColecoes[col]!.add(livro);
      }
      // Gêneros
      if (livro.genero.trim().isNotEmpty) {
        final gen = livro.genero.trim();
        if (!mapaGeneros.containsKey(gen)) {
          mapaGeneros[gen] = [];
        }
        mapaGeneros[gen]!.add(livro);
      }
    }

    if (!mounted) return;

    setState(() {
      _colecoes = mapaColecoes;
      _generos = mapaGeneros;
      _carregando = false;
    });
  }

  Widget _construirListaAgrupada(Map<String, List<Livro>> mapa, String tipo) {
    final chaves = mapa.keys.toList()..sort();

    if (chaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EFE9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                tipo == 'coleção'
                    ? Icons.collections_bookmark_outlined
                    : Icons.category_outlined,
                size: 28,
                color: const Color(0xFF48634F),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Sua biblioteca está à espera',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Nenhum livro com $tipo registrado ainda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF7C857B)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      itemCount: chaves.length,
      itemBuilder: (context, index) {
        final nome = chaves[index];
        final livros = mapa[nome]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE9EFE9),
              child: Icon(
                tipo == 'coleção' ? Icons.collections_bookmark : Icons.category,
                size: 18,
                color: const Color(0xFF48634F),
              ),
            ),
            title: Text(
              nome,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF263129),
              ),
            ),
            subtitle: Text(
              '${livros.length} livro(s)',
              style: const TextStyle(fontSize: 12, color: Color(0xFF7C857B)),
            ),
            children: livros.map((livro) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: livro.urlCapa.isNotEmpty
                      ? Image.network(
                          livro.urlCapa,
                          width: 40,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 58,
                            color: const Color(0xFFF0F2EF),
                            child: const Icon(
                              Icons.auto_stories_outlined,
                              size: 18,
                            ),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 58,
                          color: const Color(0xFFF0F2EF),
                          child: const Icon(
                            Icons.auto_stories_outlined,
                            size: 18,
                          ),
                        ),
                ),
                title: Text(
                  livro.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF263129),
                  ),
                ),
                subtitle: Text(
                  '${livro.autor} • ${livro.nota.toStringAsFixed(1)} ★',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7C857B),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF9BA49A),
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesLivro(livro: livro),
                    ),
                  );
                  _carregarDados();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca'),
          bottom: TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: const Color(0xFFE9EFE9),
              borderRadius: BorderRadius.circular(12),
            ),
            tabs: const [
              Tab(text: 'Coleções / séries'),
              Tab(text: 'Gêneros'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore sua biblioteca',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF263129),
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Histórias reunidas por gênero e coleção.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: const Color(0xFF7C857B)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _construirListaAgrupada(_colecoes, 'coleção'),
                        _construirListaAgrupada(_generos, 'gênero'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
