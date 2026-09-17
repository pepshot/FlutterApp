import 'package:flutter/material.dart';
import 'package:flutter_app/models/catalog_item.dart';
import 'package:flutter_app/widgets/stored_image.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    required this.item,
    required this.isLiked,
    required this.onLikePressed,
    required this.onTap,
    super.key,
  });

  final CatalogItem item;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: StoredImage(path: item.imagePath),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(item.description),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isLiked
                        ? 'Убрать из избранного'
                        : 'Добавить в избранное',
                    onPressed: onLikePressed,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
