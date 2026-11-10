import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personaclick_demo_shop/main.dart';
import 'package:personaclick_demo_shop/shop/shop_sort.dart';
import 'package:personaclick_sdk/personaclick_sdk.dart';

void main() {
  test('the theme takes the kit palette of its brightness', () {
    for (final brightness in Brightness.values) {
      final kit = brightness == Brightness.dark
          ? PersonalizationTheme.dark
          : PersonalizationTheme.light;
      final theme = shopTheme(brightness);
      expect(theme.colorScheme.brightness, brightness);
      expect(theme.colorScheme.primary, kit.colors.brandPrimary);
      expect(theme.colorScheme.surface, kit.colors.backgroundCard);
    }
  });

  testWidgets(
    'the sort sheet checks the current sort and returns the tapped one',
    (tester) async {
      ShopSort? picked;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  picked = await pickShopSort(context, ShopSort.relevance),
              child: const Text('Sort'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(find.text('Sort by'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text(ShopSort.priceDesc.label));
      await tester.pumpAndSettle();
      expect(picked, ShopSort.priceDesc);
      expect(picked!.sortBy, 'price');
      expect(picked!.sortDir, 'desc');
    },
  );
}
