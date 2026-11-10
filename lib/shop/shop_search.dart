import 'package:flutter/material.dart';
import 'package:personaclick_sdk/personaclick_sdk.dart';

import 'shop.dart';
import 'shop_product.dart';
import 'shop_sort.dart';

/// Search results for the submitted phrase: the kit's results screen. It loads, pages, filters
/// and tracks the search itself; its back button returns home, its sort button opens the
/// shop's sort sheet.
class ShopSearchScreen extends StatefulWidget {
  const ShopSearchScreen({
    super.key,
    required this.shopId,
    required this.query,
  });

  final String shopId;
  final String query;

  /// Opens the results on top of the current screen.
  static void open(BuildContext context, String shopId, String query) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShopSearchScreen(shopId: shopId, query: query),
      ),
    );
  }

  @override
  State<ShopSearchScreen> createState() => _ShopSearchScreenState();
}

class _ShopSearchScreenState extends State<ShopSearchScreen> {
  ShopSort _sort = ShopSort.relevance;

  Future<void> _pickSort() async {
    final sort = await pickShopSort(context, _sort);
    if (sort != null && mounted) setState(() => _sort = sort);
  }

  @override
  Widget build(BuildContext context) {
    return ShopScaffold(
      body: ShopResultsPage(
        child: PersonalizationSearchResultsScreen(
          shopId: widget.shopId,
          query: widget.query,
          sortBy: _sort.sortBy,
          sortDir: _sort.sortDir,
          productActionText: shopAddToCartText,
          onBack: () => Navigator.of(context).maybePop(),
          onSortTap: _pickSort,
          onProductTap: (product) =>
              ShopProductScreen.open(context, widget.shopId, product.id),
          onProductAction: (product) => addToShopCart(
            context,
            widget.shopId,
            product.id,
            price: product.price,
          ),
          iconBuilder: shopIcon,
        ),
      ),
    );
  }
}
