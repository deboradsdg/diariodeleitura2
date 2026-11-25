class DesafioItem {
  final String id;
  final String titulo;
  final String descricao;
  final String categoria;

  DesafioItem({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
  });

  factory DesafioItem.fromMap(Map<String, dynamic> map) {
    return DesafioItem(
      id: map['id']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? 'Geral',
    );
  }
}