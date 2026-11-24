class Livro {
  int? id;
  String titulo;
  String autor;
  String sinopse;
  String urlCapa;
  String genero;
  double nota;
  String destaque;
  bool ehColecao;
  String nomeColecao;
  String comentario;

  Livro({
    this.id,
    required this.titulo,
    required this.autor,
    required this.sinopse,
    required this.urlCapa,
    required this.genero,
    required this.nota,
    required this.destaque,
    required this.ehColecao,
    required this.nomeColecao,
    required this.comentario,
  });

  factory Livro.fromMap(Map<String, dynamic> map) {
    return Livro(
      id: map['id'],
      titulo: map['titulo'] ?? '',
      autor: map['autor'] ?? '',
      sinopse: map['sinopse'] ?? '',
      urlCapa: map['url_capa'] ?? '',
      genero: map['genero'] ?? '',
      nota: (map['nota'] as num?)?.toDouble() ?? 0.0,
      destaque: map['destaque'] ?? '',
      ehColecao: map['eh_colecao'] ?? false,
      nomeColecao: map['nome_colecao'] ?? '',
      comentario: map['comentario'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'autor': autor,
      'sinopse': sinopse,
      'url_capa': urlCapa,
      'genero': genero,
      'nota': nota,
      'destaque': destaque,
      'eh_colecao': ehColecao,
      'nome_colecao': nomeColecao,
      'comentario': comentario,
    };
  }
}