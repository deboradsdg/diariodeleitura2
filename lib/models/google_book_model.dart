class GoogleBookModel {
  final String titulo;
  final String autor;
  final String sinopse;
  final String urlCapa;

  GoogleBookModel({
    required this.titulo,
    required this.autor,
    required this.sinopse,
    required this.urlCapa,
  });

  factory GoogleBookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};

    // Autores vêm como List<dynamic>, juntamos por vírgula
    final listaAutores = (volumeInfo['authors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final autoresFormatados = listaAutores.isNotEmpty
        ? listaAutores.join(', ')
        : 'Autor desconhecido';

    // Imagens: se vier http, converte para https
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    String capa = imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';
    if (capa.startsWith('http://')) {
      capa = capa.replaceFirst('http://', 'https://');
    }

    return GoogleBookModel(
      titulo: volumeInfo['title'] ?? 'Sem título',
      autor: autoresFormatados,
      sinopse: volumeInfo['description'] ?? 'Sem sinopse disponível.',
      urlCapa: capa,
    );
  }
}