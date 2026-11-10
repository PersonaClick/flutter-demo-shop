import 'package:flutter/material.dart';
import 'package:personaclick_sdk/personaclick_sdk.dart';

import 'shop.dart';
import 'shop_product.dart';
import 'shop_sort.dart';

/// Category page: the kit's category screen. It loads `getCategory` page by page with filters
/// (brand, price and the shop's facets), switches between grid and list, shows the empty state
/// and the error with Retry, and tracks the category view once. The shop gives it the title,
/// back along its stack, the sort sheet and "Add to cart".
class ShopCategoryScreen extends StatefulWidget {
  const ShopCategoryScreen({
    super.key,
    required this.shopId,
    required this.categoryId,
    required this.name,
  });

  final String shopId;
  final String categoryId;

  /// The title: the category response carries no name, the list it was picked from does.
  final String name;

  /// Opens the category on top of the current screen.
  static void open(
    BuildContext context,
    String shopId,
    String categoryId,
    String name,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShopCategoryScreen(
          shopId: shopId,
          categoryId: categoryId,
          name: name,
        ),
      ),
    );
  }

  @override
  State<ShopCategoryScreen> createState() => _ShopCategoryScreenState();
}

class _ShopCategoryScreenState extends State<ShopCategoryScreen> {
  ShopSort _sort = ShopSort.relevance;

  Future<void> _pickSort() async {
    final sort = await pickShopSort(context, _sort);
    if (sort != null && mounted) setState(() => _sort = sort);
  }

  @override
  Widget build(BuildContext context) {
    final shopId = widget.shopId;
    return ShopScaffold(
      body: ShopResultsPage(
        child: PersonalizationCategoryScreen(
          shopId: shopId,
          categoryId: widget.categoryId,
          titleText: widget.name,
          sortBy: _sort.sortBy,
          sortDir: _sort.sortDir,
          productActionText: shopAddToCartText,
          emptyText: 'No products in this category yet.',
          errorText: shopErrorText,
          retryText: shopRetryText,
          onBack: () => Navigator.of(context).maybePop(),
          onSortTap: _pickSort,
          onProductTap: (product) =>
              ShopProductScreen.open(context, shopId, product.id),
          onProductAction: (product) =>
              addToShopCart(context, shopId, product.id, price: product.price),
          iconBuilder: shopIcon,
        ),
      ),
    );
  }
}
