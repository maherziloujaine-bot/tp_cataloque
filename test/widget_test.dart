import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_catalogue/main.dart';

void main() {
  testWidgets('Le catalogue démarre avec un panier vide', (tester) async {
    await tester.pumpWidget(const CatalogueApp());

    expect(find.text('Catalogue des formations'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.byTooltip('Mon panier'));
    await tester.pumpAndSettle();

    expect(find.text('Votre panier est vide'), findsOneWidget);
    expect(find.text('Parcourir le catalogue'), findsOneWidget);
  });
}
