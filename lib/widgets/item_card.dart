import 'package:flutter/material.dart';
import 'package:flutter_app/models/catalog_item.dart';
import 'package:flutter_app/widgets/stored_image.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    required this.item,
    super.key,
  });

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: StoredImage(path: item.imagePath),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(item.description),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
