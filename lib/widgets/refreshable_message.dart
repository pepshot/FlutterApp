import 'package:flutter/material.dart';

/// Keeps empty, loading and error states scrollable for pull-to-refresh.
class RefreshableMessage extends StatelessWidget {
  const RefreshableMessage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverFillRemaining(hasScrollBody: false, child: Center(child: child)),
    ],
  );
}
