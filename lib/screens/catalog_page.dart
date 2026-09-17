import 'package:flutter/material.dart';
import 'package:flutter_app/data/catalog_items.dart';
import 'package:flutter_app/widgets/item_card.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Languages')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: catalogItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, index) => ItemCard(
          item: catalogItems[index],
        ),
      ),
    );
  }
}
