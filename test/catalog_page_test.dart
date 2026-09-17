import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('likes a card and shows a snackbar', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Python'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('Python: добавлено в избранное'), findsOneWidget);
  });

  testWidgets('opens card details in a dialog', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Python'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Python'), findsNWidgets(2));
    expect(find.text('Описание python'), findsNWidgets(2));
    expect(find.text('Закрыть'), findsOneWidget);

    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
