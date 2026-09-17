import 'package:flutter/material.dart';

class StoredImage extends StatelessWidget {
  const StoredImage({required this.path, this.fit = BoxFit.contain, super.key});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget errorBuilder(BuildContext context, Object error, StackTrace? stack) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.broken_image_outlined, size: 52)),
      );
    }

    return Image.asset(path, fit: fit, errorBuilder: errorBuilder);
  }
}
