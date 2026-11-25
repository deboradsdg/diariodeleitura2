# 📚 Diário de Leitura

Aplicação multiplataforma (Mobile e Web) desenvolvida em **Flutter** para catalogação, resenha e acompanhamento de metas literárias pessoais. O projeto integra persistência em nuvem via **Supabase** e busca automatizada de metadados através de APIs REST literárias (**Open Library** e **Google Books**).

🌐 **Acesse a versão Web:** [https://deboradsdg.github.io/diariodeleitura/](https://deboradsdg.github.io/diariodeleitura/)

---

## 🎯 Funcionalidades

- **CRUD Completo de Livros:** Cadastro, visualização detalhada, edição integral (título, autor, capa via URL, sinopse, resenha pessoal, nota, gênero e coleção) e exclusão.
- **Busca Online Inteligente:** Pesquisa integrada que lista múltiplas edições para seleção do usuário, com fallback automático entre Open Library e Google Books.
- **Organização por Coleções e Gêneros:** Visualização agrupada por categorias e séries literárias através de abas dinâmicas.
- **Desafios Literários Persistentes:**
  - Sistema de metas estruturado no banco de dados (`desafio_leitura` e `progresso_desafio`).
  - Desafios pré-catalogados: *Volta ao Brasil (26 Estados + DF)*, *América Latina*, *Eurotour*, *África*, *Ásia* e *Desafio 2027*.
  - Criação dinâmica de novas categorias e metas pelo usuário.
  - Vinculação de livros do diário a cada meta com cálculo automático de progresso percentual.
- **Interface Otimizada:** Layout em grade responsiva, visualização compacta de capas e navegação nativa.

---

## 🛠️ Tecnologias e Bibliotecas

- **Linguagem:** [Dart](https://dart.dev/)
- **Framework:** [Flutter](https://flutter.dev/) (Suporte Android e Web)
- **Backend as a Service:** [Supabase](https://supabase.com/) (`supabase_flutter: ^2.8.0`)
- **Consumo HTTP / REST:** [http](https://pub.dev/packages/http) (`http: ^1.2.0`)
- **APIs Externas:** Open Library Search API & Google Books API
- **Hospedagem Web:** GitHub Pages (branch `gh-pages`)

---

## 🏗️ Estrutura do Projeto

```text
lib/
├── models/
│   ├── desafio_item.dart        # Modelo para metas e categorias de desafios
│   ├── google_book_model.dart   # Modelo para tratamento dos dados retornados pelas APIs
│   └── livro.dart               # Modelo principal da entidade Livro
├── screens/
│   ├── cadastro_desafio.dart    # Formulário para criação de novos desafios no Supabase
│   ├── cadastro_livro.dart      # Cadastro manual/online com modal de seleção
│   ├── detalhe_desafio.dart     # Lista de metas, vinculação de livros e progresso
│   ├── detalhes_livro.dart      # Exibição e edição completa das informações da leitura
│   ├── lista_colecoes.dart      # Visualização agrupada por Coleções e Gêneros
│   ├── tela_desafios.dart       # Listagem das categorias de desafios cadastradas
│   └── tela_principal.dart      # Grade principal de livros com filtros rápidos
├── services/
│   ├── api_services.dart        # Requisições REST às APIs literárias externas
│   └── data_access_object.dart  # Métodos CRUD integrados à tabela 'livros' do Supabase
└── main.dart                    # Inicialização do app, configurações de tema e rotas