import 'package:flutter/material.dart';
import 'package:flutter_app/data/catalog_items.dart';
import 'package:flutter_app/widgets/item_card.dart';
import 'package:flutter_app/widgets/stored_image.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final Set<int> _likedItems = <int>{};

  void _toggleLike(int index) {
    setState(() {
      if (!_likedItems.add(index)) {
        _likedItems.remove(index);
      }
    });

    final item = catalogItems[index];
    final isLiked = _likedItems.contains(index);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isLiked
                ? '${item.title}: добавлено в избранное'
                : '${item.title}: удалено из избранного',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showDetails(int index) {
    final item = catalogItems[index];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: StoredImage(path: item.imagePath),
            ),
            const SizedBox(height: 16),
            Text(item.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

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
          isLiked: _likedItems.contains(index),
          onLikePressed: () => _toggleLike(index),
          onTap: () => _showDetails(index),
        ),
      ),
    );
  }
}
