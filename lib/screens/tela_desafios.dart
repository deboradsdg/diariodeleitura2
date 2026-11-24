import 'package:flutter/material.dart';
import '../models/desafio_item.dart';
import 'detalhe_desafio.dart';

class TelaDesafios extends StatelessWidget {
  const TelaDesafios({super.key});

  @override
  Widget build(BuildContext context) {
    final desafios = DesafioItem.obterDesafiosPredefinidos();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Desafios de Leitura', style: TextStyle(fontSize: 18)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: desafios.length,
        itemBuilder: (context, index) {
          final desafio = desafios[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.emoji_events_outlined),
              ),
              title: Text(
                desafio.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  desafio.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalheDesafio(desafio: desafio),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}