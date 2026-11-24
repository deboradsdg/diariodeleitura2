import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/google_book_model.dart';

class ApiServices {
  static Future<List<GoogleBookModel>> buscarLivros({String termo = ''}) async {
    final query = termo.trim();
    if (query.isEmpty) return [];

    List<GoogleBookModel> resultados = [];

    // 1. Tentar primeiro na Open Library (mais flexível e sem bloqueio 429 frequente)
    try {
      final urlOpenLib = Uri.https('openlibrary.org', '/search.json', {
        'q': query,
        'limit': '5',
      });

      final respostaOpen = await http.get(urlOpenLib);

      if (respostaOpen.statusCode == 200) {
        final dados = jsonDecode(respostaOpen.body);
        final docs = dados['docs'] as List<dynamic>?;

        if (docs != null && docs.isNotEmpty) {
          for (var doc in docs) {
            final titulo = doc['title']?.toString() ?? 'Sem título';
            final autores = (doc['author_name'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .join(', ') ??
                'Autor desconhecido';

            final coverId = doc['cover_i'];
            final capa = coverId != null
                ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
                : '';

            resultados.add(
              GoogleBookModel(
                titulo: titulo,
                autor: autores,
                sinopse: '', // O usuário digitará manualmente
                urlCapa: capa,
              ),
            );
          }
          if (resultados.isNotEmpty) return resultados;
        }
      }
    } catch (e) {
      debugPrint("Erro no Open Library: $e");
    }

    // 2. Fallback caso a Open Library não devolva resultados
    try {
      final urlGoogle = Uri.https('www.googleapis.com', '/books/v1/volumes', {
        'q': query,
        'maxResults': '5',
      });

      final respostaGoogle = await http.get(urlGoogle);

      if (respostaGoogle.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(respostaGoogle.body);
        final itens = dados['items'] as List<dynamic>?;

        if (itens != null && itens.isNotEmpty) {
          for (var item in itens) {
            if (item['volumeInfo'] != null) {
              resultados.add(GoogleBookModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Erro no Google Books: $e");
    }

    return resultados;
  }
}