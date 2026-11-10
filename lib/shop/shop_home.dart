import 'package:flutter/material.dart';
import 'package:personaclick_sdk/personaclick_sdk.dart';

import '../shop_config.dart';
import 'shop.dart';
import 'shop_category.dart';
import 'shop_product.dart';
import 'shop_products.dart';
import 'shop_search_field.dart';

/// The shop's home, built from the kit and the public SDK methods, under the status bar:
/// - the header: "Shop" and the search button. Search puts the kit's instant search in place
///   of the header, its panel open with Cancel, the rest of home out of the way (see
///   [ShopSearchField]);
/// - the stories bar, only when a stories block is set ([storiesCode]): a product in a story
///   opens the product page;
/// - the recommender block as a carousel, the title from the answer: a tap opens the product,
///   the card button adds it to the cart;
/// - categories: the top-level categories of the products list, a tap opens the category page.
///
/// Category, product and search pages go on the app's navigator, so back walks them in
/// reverse. No page of the shop has an app bar: each starts under the status bar. "Add to
/// cart" sends the cart event and shows a toast — there is no cart screen.
class ShopPane extends StatefulWidget {
  const ShopPane({super.key, required this.shopId});

  final String shopId;

  @override
  State<ShopPane> createState() => _ShopPaneState();
}

/// Height of a row of the categories group.
const double _categoryRowHeight = 52;

class _ShopPaneState extends State<ShopPane> {
  /// Top-level categories; `null` while they load.
  List<ProductCategory>? _categories;
  Object? _categoriesError;

  /// Products of the recommender block: hidden, it takes no room, so its gap goes too.
  int _popularCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // The listing is only read for its categories, which come with it whatever the page
      // size: a few products are enough.
      final response = await PersonaClick.getInstance(
        widget.shopId,
      ).getProductsList(params: const ProductsListParams(limit: 10));
      if (mounted) setState(() => _categories = shopTopCategories(response));
    } catch (error) {
      if (mounted) setState(() => _categoriesError = error);
    }
  }

  void _retryCategories() {
    setState(() => _categoriesError = null);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final colors = PersonalizationTheme.of(context).colors;
    final safe = MediaQuery.paddingOf(context);
    return ShopScaffold(
      // Search mode puts the field in place of the header and the panel under it.
      body: ShopSearchField(
        shopId: widget.shopId,
        builder: (context, field, searching, search) => SingleChildScrollView(
          padding: EdgeInsets.only(
            top: safe.top + PersonalizationSpacing.md,
            bottom: safe.bottom + PersonalizationSpacing.xl4,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PersonalizationSpacing.paddingX,
                ),
                child: searching
                    ? field
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Shop',
                              style: shopTextStyle(
                                context,
                                PersonalizationTypography.xl3Emphasized,
                                colors.textPrimary,
                              ),
                            ),
                          ),
                          ShopRoundButton(
                            icon: PersonalizationIcons.magnifier,
                            label: 'Search',
                            onPressed: search,
                          ),
                        ],
                      ),
              ),
              // Offstage, not removed: the sections keep what they loaded.
              Offstage(offstage: searching, child: _home(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _home(BuildContext context) {
    final shopId = widget.shopId;
    const side = EdgeInsets.symmetric(
      horizontal: PersonalizationSpacing.paddingX,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // No stories block, no bar. The bar runs edge to edge, its covers start at the
        // page's margin; it collapses when the block is empty or fails. A product of a story
        // closes the viewer and opens here; other links go to the system.
        if (storiesCode.isNotEmpty) ...[
          const SizedBox(height: PersonalizationSpacing.lg),
          PersonalizationStories(
            code: storiesCode,
            shopId: shopId,
            padding: side,
            promoCopiedText: shopPromoCopiedText,
            onProductClick: (product) =>
                ShopProductScreen.open(context, shopId, product.id),
            iconBuilder: shopIcon,
          ),
        ],
        if (_popularCount > 0)
          const SizedBox(height: PersonalizationSpacing.xl3),
        // Title from the response; hidden until its products arrive, and for good when the
        // answer is empty (segment A of the shop's A/B test). The card button remembers the
        // block as the source before the cart event goes out.
        Padding(
          padding: side,
          child: PersonalizationRecommenderBlock(
            code: homePopularCode,
            shopId: shopId,
            actionText: shopAddToCartText,
            onLoaded: (count) {
              if (mounted && _popularCount != count) {
                setState(() => _popularCount = count);
              }
            },
            onProductTap: (product) =>
                ShopProductScreen.open(context, shopId, product.id),
            onProductAction: (product) =>
                addToShopCart(context, shopId, product.id),
            iconBuilder: shopIcon,
          ),
        ),
        Padding(padding: side, child: _categoriesSection(context)),
      ],
    );
  }

  /// "Categories": the kit's title over a group of rows. Hidden whole while there are none; a
  /// failure shows the shop's retry in place of the group.
  Widget _categoriesSection(BuildContext context) {
    final categories = _categories;
    final Widget content;
    if (_categoriesError != null) {
      content = ShopRetry(onRetry: _retryCategories);
    } else if (categories == null) {
      content = const Center(child: PersonalizationLoader());
    } else if (categories.isEmpty) {
      return const SizedBox.shrink();
    } else {
      content = _ShopCategoryGroup(
        shopId: widget.shopId,
        categories: categories,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: PersonalizationSpacing.xl3),
        // The same title as the recommender block's.
        const PersonalizationTitle(title: 'Categories'),
        const SizedBox(height: PersonalizationSpacing.lg),
        content,
      ],
    );
  }
}

/// Categories as one group on the kit's card: the kit's category rows, a hairline between
/// them, the whole row opens its category.
class _ShopCategoryGroup extends StatelessWidget {
  const _ShopCategoryGroup({required this.shopId, required this.categories});

  final String shopId;
  final List<ProductCategory> categories;

  @override
  Widget build(BuildContext context) {
    final theme = PersonalizationTheme.of(context);
    final colors = theme.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radius.card),
      child: ColoredBox(
        color: colors.backgroundCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, category) in categories.indexed) ...[
              if (index > 0)
                SizedBox(
                  height: 1,
                  child: ColoredBox(color: colors.lineGenericSubtle),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ShopCategoryScreen.open(
                  context,
                  shopId,
                  category.id,
                  category.name,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: _categoryRowHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PersonalizationSpacing.paddingX,
                    ),
                    child: Center(
                      child: PersonalizationSuggestionRow(
                        kind: PersonalizationSuggestionKind.category,
                        title: category.name,
                        iconBuilder: shopIcon,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
