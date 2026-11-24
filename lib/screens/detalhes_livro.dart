import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/data_access_object.dart';

class DetalhesLivro extends StatefulWidget {
  final Livro livro;

  const DetalhesLivro({super.key, required this.livro});

  @override
  State<DetalhesLivro> createState() => _DetalhesLivroState();
}

class _DetalhesLivroState extends State<DetalhesLivro> {
  late Livro _livro;
  bool _modoEdicao = false;
  bool _salvando = false;
  bool _excluindo = false;

  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late TextEditingController _urlCapaController;
  late TextEditingController _sinopseController;
  late TextEditingController _generoController;
  late TextEditingController _destaqueController;
  late TextEditingController _comentarioController;
  late TextEditingController _colecaoController;
  late double _nota;
  late bool _ehColecao;

  @override
  void initState() {
    super.initState();
    _livro = widget.livro;
    _inicializarControllers();
  }

  void _inicializarControllers() {
    _tituloController = TextEditingController(text: _livro.titulo);
    _autorController = TextEditingController(text: _livro.autor);
    _urlCapaController = TextEditingController(text: _livro.urlCapa);
    _sinopseController = TextEditingController(text: _livro.sinopse);
    _generoController = TextEditingController(text: _livro.genero);
    _destaqueController = TextEditingController(text: _livro.destaque);
    _comentarioController = TextEditingController(text: _livro.comentario);
    _colecaoController = TextEditingController(text: _livro.nomeColecao);
    _nota = _livro.nota;
    _ehColecao = _livro.ehColecao;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _urlCapaController.dispose();
    _sinopseController.dispose();
    _generoController.dispose();
    _destaqueController.dispose();
    _comentarioController.dispose();
    _colecaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    setState(() {
      _salvando = true;
    });

    final livroAtualizado = Livro(
      id: _livro.id,
      titulo: _tituloController.text.trim(),
      autor: _autorController.text.trim(),
      urlCapa: _urlCapaController.text.trim(),
      sinopse: _sinopseController.text.trim(),
      genero: _generoController.text.trim(),
      nota: _nota,
      destaque: _destaqueController.text.trim(),
      ehColecao: _ehColecao,
      nomeColecao: _ehColecao ? _colecaoController.text.trim() : '',
      comentario: _comentarioController.text.trim(),
    );

    await DataAccessObject.alterarLivro(livroAtualizado);

    if (!mounted) return;

    setState(() {
      _livro = livroAtualizado;
      _modoEdicao = false;
      _salvando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro atualizado com sucesso!')),
    );
  }

  Future<void> _excluir() async {
    if (_livro.id == null) return;

    setState(() {
      _excluindo = true;
    });

    final sucesso = await DataAccessObject.excluirLivro(_livro.id!);

    if (!mounted) return;

    setState(() {
      _excluindo = false;
    });

    if (sucesso) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao excluir o livro.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoEdicao ? 'Editar Livro' : _livro.titulo),
        actions: [
          if (!_modoEdicao) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar informações',
              onPressed: () => setState(() => _modoEdicao = true),
            ),
            IconButton(
              icon: _excluindo
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded),
              tooltip: 'Excluir',
              onPressed: _excluindo ? null : _excluir,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Cancelar edição',
              onPressed: () {
                _inicializarControllers();
                setState(() => _modoEdicao = false);
              },
            ),
          ],
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: _modoEdicao
                ? _construirFormularioEdicao()
                : _construirVisualizacao(),
          ),
        ),
      ),
    );
  }

  Widget _construirVisualizacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 600;
            final detalhes = Column(
              crossAxisAlignment: compacto
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUA LEITURA',
                  style: TextStyle(
                    color: Color(0xFF718071),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _livro.titulo,
                  textAlign: compacto ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF263129),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _livro.autor.isNotEmpty
                      ? _livro.autor
                      : 'Autor não informado',
                  textAlign: compacto ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: const Color(0xFF7C857B)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: compacto
                      ? WrapAlignment.center
                      : WrapAlignment.start,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      avatar: const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFD59B42),
                        size: 18,
                      ),
                      label: Text(_livro.nota.toStringAsFixed(1)),
                    ),
                    if (_livro.genero.isNotEmpty)
                      Chip(label: Text(_livro.genero)),
                    if (_livro.ehColecao && _livro.nomeColecao.isNotEmpty)
                      Chip(label: Text(_livro.nomeColecao)),
                  ],
                ),
              ],
            );

            if (compacto) {
              return Column(
                children: [
                  _construirCapaLivro(),
                  const SizedBox(height: 22),
                  detalhes,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _construirCapaLivro(),
                const SizedBox(width: 32),
                Expanded(child: detalhes),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        if (_livro.destaque.isNotEmpty) ...[
          _construirSecaoLeitura(
            'O que mais gostou',
            Icons.format_quote_rounded,
            _livro.destaque,
            destaque: true,
          ),
        ],
        if (_livro.comentario.isNotEmpty) ...[
          _construirSecaoLeitura(
            'Comentários e resenha',
            Icons.edit_note_rounded,
            _livro.comentario,
          ),
        ],
        _construirSecaoLeitura(
          'Sinopse',
          Icons.menu_book_outlined,
          _livro.sinopse.isNotEmpty
              ? _livro.sinopse
              : 'Nenhuma sinopse registrada.',
        ),
      ],
    );
  }

  Widget _construirCapaLivro() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _livro.urlCapa.isNotEmpty
          ? Image.network(
              _livro.urlCapa,
              width: 144,
              height: 216,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _construirCapaVazia(),
            )
          : _construirCapaVazia(),
    );
  }

  Widget _construirCapaVazia() {
    return Container(
      width: 144,
      height: 216,
      color: const Color(0xFFE9EFE9),
      child: const Icon(
        Icons.auto_stories_outlined,
        size: 42,
        color: Color(0xFF718071),
      ),
    );
  }

  Widget _construirSecaoLeitura(
    String titulo,
    IconData icone,
    String texto, {
    bool destaque = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: const Color(0xFF48634F), size: 20),
                const SizedBox(width: 9),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF263129),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              texto,
              style: TextStyle(
                color: const Color(0xFF59645A),
                fontSize: 14,
                height: 1.65,
                fontStyle: destaque ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFormularioEdicao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Editar sua leitura',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF263129),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Atualize os dados e suas impressões sobre o livro.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: const Color(0xFF7C857B)),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _urlCapaController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'URL da Capa',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tituloController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Título',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _autorController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Autor',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _sinopseController,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Sinopse',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sua experiência de leitura',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF263129),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _generoController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Gênero',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Nota: ${_nota.toStringAsFixed(1)} ★',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Slider(
                value: _nota,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                onChanged: (val) => setState(() => _nota = val),
              ),
            ),
          ],
        ),
        TextField(
          controller: _destaqueController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'O que mais gostou',
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Faz parte de coleção?'),
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
            labelText: 'Comentários',
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _salvando ? null : _salvarAlteracoes,
          icon: _salvando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_rounded),
          label: Text(_salvando ? 'Salvando...' : 'Salvar Alterações'),
        ),
      ],
    );
  }
}
