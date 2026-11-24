class DesafioItem {
  final String id;
  final String titulo;
  final String descricao;
  final List<String> metas; // Ex: Lista dos 27 estados, países ou categorias

  DesafioItem({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.metas,
  });

  // Lista pré-configurada com todos os desafios que você pediu
  static List<DesafioItem> obterDesafiosPredefinidos() {
    return [
      DesafioItem(
        id: 'estados_br',
        titulo: 'Volta ao Brasil em 26 Estados + DF',
        descricao: 'Leia um livro representativo de cada unidade federativa do Brasil.',
        metas: [
          'Acre (AC)', 'Alagoas (AL)', 'Amapá (AP)', 'Amazonas (AM)', 'Bahia (BA)',
          'Ceará (CE)', 'Distrito Federal (DF)', 'Espírito Santo (ES)', 'Goiás (GO)',
          'Maranhão (MA)', 'Mato Grosso (MT)', 'Mato Grosso do Sul (MS)', 'Minas Gerais (MG)',
          'Pará (PA)', 'Paraíba (PB)', 'Paraná (PR)', 'Pernambuco (PE)', 'Piauí (PI)',
          'Rio de Janeiro (RJ)', 'Rio Grande do Norte (RN)', 'Rio Grande do Sul (RS)',
          'Rondônia (RO)', 'Roraima (RR)', 'Santa Catarina (SC)', 'São Paulo (SP)',
          'Sergipe (SE)', 'Tocantins (TO)'
        ]..sort(),
      ),
      DesafioItem(
        id: 'america_latina',
        titulo: 'América Latina',
        descricao: 'Leia um autor ou história ambientada em cada país latino-americano.',
        metas: [
          'Argentina', 'Bolívia', 'Brasil', 'Chile', 'Colômbia', 'Costa Rica', 'Cuba',
          'Equador', 'El Salvador', 'Guatemala', 'Haiti', 'Honduras', 'México',
          'Nicarágua', 'Panamá', 'Paraguai', 'Peru', 'República Dominicana',
          'Uruguai', 'Venezuela'
        ]..sort(),
      ),
      DesafioItem(
        id: 'eurotour',
        titulo: 'Eurotour Literário',
        descricao: 'Um tour literário lendo uma obra de cada país europeu.',
        metas: [
          'Alemanha', 'Áustria', 'Bélgica', 'Croácia', 'Dinamarca', 'Espanha',
          'Finlândia', 'França', 'Grécia', 'Holanda', 'Hungria', 'Irlanda',
          'Islândia', 'Itália', 'Noruega', 'Polônia', 'Portugal', 'Reino Unido',
          'República Tcheca', 'Rússia', 'Suécia', 'Suíça', 'Ucrânia'
        ]..sort(),
      ),
      DesafioItem(
        id: 'africa',
        titulo: 'Desafio Literário Africano',
        descricao: 'Obras de autores de países do continente africano.',
        metas: [
          'África do Sul', 'Angola', 'Argélia', 'Cabo Verde', 'Camarões', 'Egito',
          'Etiópia', 'Gana', 'Marrocos', 'Moçambique', 'Nigéria', 'Quênia',
          'Senegal', 'Tanzânia', 'Tunísia'
        ]..sort(),
      ),
      DesafioItem(
        id: 'asia',
        titulo: 'Desafio Literário Asiático',
        descricao: 'Explore a literatura de países do continente asiático.',
        metas: [
          'Arábia Saudita', 'Camboja', 'China', 'Coreia do Sul', 'Emirados Árabes',
          'Filipinas', 'Índia', 'Indonésia', 'Irã', 'Israel', 'Japão',
          'Líbano', 'Malásia', 'Rússia Asiática', 'Tailândia', 'Turquia', 'Vietnã'
        ]..sort(),
      ),
      DesafioItem(
        id: 'desafio_2027',
        titulo: 'Desafio de Leitura 2027',
        descricao: 'Variedade de estilos, gêneros e linguagens para o ano de 2027.',
        metas: [
          'Biografia ou Autobiografia',
          'Clássico da Literatura',
          'Contos ou Crônicas',
          'Distopia ou Ficção Científica',
          'Graphic Novel ou Mangá',
          'Livro de Autor Nacional Contemporâneo',
          'Livro de Fantasia',
          'Livro de Não Ficção',
          'Livro de Poesia',
          'Livro de Romance de Época',
          'Livro Técnico / Profissional',
          'Livro com Mais de 400 Páginas',
          'Suspense ou Terror'
        ]..sort(),
      ),
    ];
  }
}