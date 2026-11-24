import 'package:flutter/material.dart';

import '../models/google_book_model.dart';
import '../models/livro.dart';
import '../services/api_services.dart';
import '../services/data_access_object.dart';

class CadastroLivro extends StatefulWidget {
  const CadastroLivro({super.key});

  @override
  State<CadastroLivro> createState() => _CadastroLivroState();
}

class _CadastroLivroState extends State<CadastroLivro> {
  final _buscaController = TextEditingController();
  bool _carregandoBusca = false;
  bool _salvando = false;

  final _urlCapaController = TextEditingController();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _sinopseController = TextEditingController();

  final _generoController = TextEditingController();
  final _destaqueController = TextEditingController();
  final _comentarioController = TextEditingController();
  final _colecaoController = TextEditingController();

  double _nota = 5.0;
  bool _ehColecao = false;

  @override
  void dispose() {
    _buscaController.dispose();
    _urlCapaController.dispose();
    _tituloController.dispose();
    _autorController.dispose();
    _sinopseController.dispose();
    _generoController.dispose();
    _destaqueController.dispose();
    _comentarioController.dispose();
    _colecaoController.dispose();
    super.dispose();
  }

  Future<void> _executarBusca() async {
    if (_buscaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o título para buscar')),
      );
      return;
    }

    setState(() {
      _carregandoBusca = true;
    });

    final List<GoogleBookModel> resultados = await ApiServices.buscarLivros(
      termo: _buscaController.text,
    );

    if (!mounted) return;

    setState(() {
      _carregandoBusca = false;
    });

    if (resultados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum livro encontrado. Preencha os campos manualmente.',
          ),
        ),
      );
      return;
    }

    _mostrarModalSelecao(resultados);
  }

  void _mostrarModalSelecao(List<GoogleBookModel> opcoes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Selecione a edição correta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: opcoes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = opcoes[index];
                    return ListTile(
                      leading: item.urlCapa.isNotEmpty
                          ? Image.network(
                              item.urlCapa,
                              width: 40,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.book),
                            )
                          : const Icon(Icons.book, size: 40),
                      title: Text(
                        item.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item.autor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _tituloController.text = item.titulo;
                          _autorController.text = item.autor;
                          _sinopseController.text = item.sinopse;
                          _urlCapaController.text = item.urlCapa;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _salvarLivro() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe ao menos o título do livro.')),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    final novoLivro = Livro(
      titulo: _tituloController.text.trim(),
      autor: _autorController.text.trim(),
      sinopse: _sinopseController.text.trim(),
      urlCapa: _urlCapaController.text.trim(),
      genero: _generoController.text.trim(),
      nota: _nota,
      destaque: _destaqueController.text.trim(),
      ehColecao: _ehColecao,
      nomeColecao: _ehColecao ? _colecaoController.text.trim() : '',
      comentario: _comentarioController.text.trim(),
    );

    await DataAccessObject.incluirLivro(novoLivro);

    if (!mounted) return;

    setState(() {
      _salvando = false;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova leitura')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guarde uma nova história',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: const Color(0xFF263129),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Registre os detalhes e suas impressões de leitura.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: const Color(0xFF7C857B)),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _buscaController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Buscar um livro online',
                              hintText: 'Ex.: Orgulho e Preconceito',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _carregandoBusca ? null : _executarBusca,
                          child: _carregandoBusca
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Buscar'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Prévia da Capa
                if (_urlCapaController.text.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 120,
                        height: 176,
                        child: Image.network(
                          _urlCapaController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.auto_stories_outlined, size: 42),
                        ),
                      ),
                    ),
                  ),
                if (_urlCapaController.text.isNotEmpty)
                  const SizedBox(height: 16),

                Text(
                  'Sobre o livro',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF263129),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _urlCapaController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Link da Imagem da Capa (URL)',
                    hintText: 'https://...',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Título do Livro',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _autorController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Autor(a)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sinopseController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sinopse do Livro (digite ou edite aqui)',
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: Color(0xFF48634F),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sua experiência de leitura',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF263129),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),

                TextField(
                  controller: _generoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Gênero literário',
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F2E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFD59B42),
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _nota.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF695630),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _nota,
                        min: 1.0,
                        max: 5.0,
                        divisions: 8,
                        label: _nota.toStringAsFixed(1),
                        onChanged: (val) => setState(() => _nota = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _destaqueController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'O que mais gostou no livro?',
                  ),
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Faz parte de uma série/coleção?'),
                  value: _ehColecao,
                  onChanged: (val) => setState(() => _ehColecao = val),
                ),
                if (_ehColecao) ...[
                  TextField(
                    controller: _colecaoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nome da Coleção',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                TextField(
                  controller: _comentarioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Comentário ou resenha geral',
                  ),
                ),
                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _salvando ? null : _salvarLivro,
                  icon: _salvando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_salvando ? 'Salvando...' : 'Salvar no Diário'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
