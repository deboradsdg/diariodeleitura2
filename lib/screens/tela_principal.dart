import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/data_access_object.dart';
import 'cadastro_livro.dart';
import 'detalhes_livro.dart';
import 'lista_colecoes.dart';
import 'tela_desafios.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List<Livro> _livros = [];
  bool _carregando = true;
  String _filtroAtual = 'todos';
  String? _valorFiltro;

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  Future<void> _carregarLivros() async {
    setState(() {
      _carregando = true;
    });

    List<Livro> lista;
    if (_filtroAtual == 'genero' && _valorFiltro != null) {
      lista = await DataAccessObject.obterLivrosPorGenero(_valorFiltro!);
    } else if (_filtroAtual == 'colecao' && _valorFiltro != null) {
      lista = await DataAccessObject.obterLivrosPorColecao(_valorFiltro!);
    } else {
      lista = await DataAccessObject.obterLivros();
    }

    setState(() {
      _livros = lista;
      _carregando = false;
    });
  }

  void _abrirSelecaoFiltro(String tipo) async {
    final todos = await DataAccessObject.obterLivros();
    List<String> opcoes = [];

    if (tipo == 'genero') {
      opcoes = todos
          .map((l) => l.genero)
          .where((g) => g.trim().isNotEmpty)
          .toSet()
          .toList();
    } else {
      opcoes = todos
          .where((l) => l.ehColecao && l.nomeColecao.trim().isNotEmpty)
          .map((l) => l.nomeColecao)
          .toSet()
          .toList();
    }

    if (!mounted) return;

    if (opcoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum(a) $tipo cadastrado(a) ainda.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          itemCount: opcoes.length,
          itemBuilder: (ctx, index) {
            final item = opcoes[index];
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  tipo == 'genero'
                      ? Icons.category_outlined
                      : Icons.auto_stories_outlined,
                ),
              ),
              title: Text(item),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _filtroAtual = tipo;
                  _valorFiltro = item;
                });
                _carregarLivros();
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Leitura'),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_outlined),
            tooltip: 'Ver Coleções e Gêneros',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListaColecoes()),
              );
              _carregarLivros();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar biblioteca',
            onPressed: () {
              setState(() {
                _filtroAtual = 'todos';
                _valorFiltro = null;
              });
              _carregarLivros();
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Desafios Literários',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TelaDesafios()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sua biblioteca',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: const Color(0xFF263129),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.7,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uma estante feita de histórias suas.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: const Color(0xFF7C857B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EFE9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF48634F),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_livros.length}',
                        style: const TextStyle(
                          color: Color(0xFF48634F),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                FilterChip(
                  showCheckmark: false,
                  label: const Text('Todos'),
                  selected: _filtroAtual == 'todos',
                  onSelected: (selected) {
                    setState(() {
                      _filtroAtual = 'todos';
                      _valorFiltro = null;
                    });
                    _carregarLivros();
                  },
                ),
                const SizedBox(width: 6),
                FilterChip(
                  showCheckmark: false,
                  label: Text(
                    _filtroAtual == 'genero' && _valorFiltro != null
                        ? 'Gênero: $_valorFiltro'
                        : 'Por Gênero',
                  ),
                  selected: _filtroAtual == 'genero',
                  onSelected: (selected) => _abrirSelecaoFiltro('genero'),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  showCheckmark: false,
                  label: Text(
                    _filtroAtual == 'colecao' && _valorFiltro != null
                        ? 'Coleção: $_valorFiltro'
                        : 'Por Coleção',
                  ),
                  selected: _filtroAtual == 'colecao',
                  onSelected: (selected) => _abrirSelecaoFiltro('colecao'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Grade compacta de 3 colunas
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _livros.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EFE9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.auto_stories_outlined,
                            size: 30,
                            color: Color(0xFF48634F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sua estante está à espera',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Adicione um livro para começar seu diário.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF7C857B)),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final colunas = constraints.maxWidth >= 1100
                          ? 5
                          : constraints.maxWidth >= 760
                          ? 4
                          : constraints.maxWidth >= 520
                          ? 3
                          : 2;

                      return GridView.builder(
                        padding: const EdgeInsets.all(18),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: colunas,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: _livros.length,
                        itemBuilder: (context, index) {
                          final livro = _livros[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalhesLivro(livro: livro),
                                  ),
                                );
                                _carregarLivros();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: livro.urlCapa.isNotEmpty
                                        ? Image.network(
                                            livro.urlCapa,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  color: const Color(
                                                    0xFFF0F2EF,
                                                  ),
                                                  child: const Icon(
                                                    Icons.auto_stories_outlined,
                                                    size: 32,
                                                    color: Color(0xFF9BA49A),
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            color: const Color(0xFFF0F2EF),
                                            child: const Icon(
                                              Icons.auto_stories_outlined,
                                              size: 32,
                                              color: Color(0xFF9BA49A),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      10,
                                      12,
                                      12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          livro.titulo,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF263129),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          livro.autor,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF7C857B),
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 14,
                                              color: Color(0xFFD59B42),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              livro.nota.toStringAsFixed(1),
                                              style: const TextStyle(
                                                color: Color(0xFF59645A),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final adicionou = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroLivro()),
          );
          if (adicionou == true) {
            _carregarLivros();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar livro'),
      ),
    );
  }
}
