import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/livro.dart';

class DataAccessObject {
  static final _supabase = Supabase.instance.client;

  // C: Create (incluir livro)
  static Future<void> incluirLivro(Livro livro) async {
    try {
      await _supabase.from('livros').insert(livro.toMap());
    } catch (erro) {
      debugPrint("Erro ao inserir livro: $erro");
    }
  }

  // R: Read (obter todos os livros)
  static Future<List<Livro>> obterLivros() async {
    try {
      final List<dynamic> resposta = await _supabase
          .from('livros')
          .select()
          .order('titulo', ascending: true);

      return resposta.map((item) => Livro.fromMap(item as Map<String, dynamic>)).toList();
    } catch (erro) {
      debugPrint("Erro ao buscar livros: $erro");
      return [];
    }
  }

  // R: Read por Gênero
  static Future<List<Livro>> obterLivrosPorGenero(String genero) async {
    try {
      final List<dynamic> resposta = await _supabase
          .from('livros')
          .select()
          .eq('genero', genero)
          .order('titulo', ascending: true);

      return resposta.map((item) => Livro.fromMap(item as Map<String, dynamic>)).toList();
    } catch (erro) {
      debugPrint("Erro ao buscar livros por gênero: $erro");
      return [];
    }
  }

  // R: Read por Coleção
  static Future<List<Livro>> obterLivrosPorColecao(String nomeColecao) async {
    try {
      final List<dynamic> resposta = await _supabase
          .from('livros')
          .select()
          .eq('nome_colecao', nomeColecao)
          .order('titulo', ascending: true);

      return resposta.map((item) => Livro.fromMap(item as Map<String, dynamic>)).toList();
    } catch (erro) {
      debugPrint("Erro ao buscar livros por coleção: $erro");
      return [];
    }
  }

  // U: Update (alterar dados do livro)
  static Future<void> alterarLivro(Livro livro) async {
    try {
      if (livro.id != null) {
        await _supabase
            .from('livros')
            .update(livro.toMap())
            .eq('id', livro.id!);
      }
    } catch (erro) {
      debugPrint("Erro ao atualizar livro: $erro");
    }
  }

  // D: Delete (excluir livro por ID)
  static Future<bool> excluirLivro(int id) async {
    try {
      await _supabase.from('livros').delete().eq('id', id);
      return true;
    } catch (erro) {
      debugPrint("Erro ao excluir livro: $erro");
      return false;
    }
  }
}