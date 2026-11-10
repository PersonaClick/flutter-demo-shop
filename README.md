# PersonaClick Flutter SDK — demo shop

A small shop app for Android and iOS built from the UI kit and the public methods of the
PersonaClick Flutter SDK: home with instant search, recommendations and categories, category
pages with filters and sorting, product pages with recommendations, and search results.

The SDK is published on pub.dev as
[`personaclick_sdk`](https://pub.dev/packages/personaclick_sdk); the UI kit comes in the same
package (`package:personaclick_sdk/personaclick_sdk.dart`).

The demo is deliberately small: everything lives in `lib` and reads in a few minutes.

## What it demonstrates

| Scenario | Where to look |
| --- | --- |
| SDK initialization, the theme follows the system (light / dark) | [`lib/main.dart`](lib/main.dart) |
| Home: instant search, "Popular products" recommender block, categories | [`lib/shop/shop_home.dart`](lib/shop/shop_home.dart), [`lib/shop/shop_search_field.dart`](lib/shop/shop_search_field.dart) |
| Category page: filters (brand, price), sorting, grid / list | [`lib/shop/shop_category.dart`](lib/shop/shop_category.dart), [`lib/shop/shop_sort.dart`](lib/shop/shop_sort.dart) |
| Product page: details, "Similar products", "Recently viewed", product view tracking | [`lib/shop/shop_product.dart`](lib/shop/shop_product.dart) |
| Search results with filters and sorting | [`lib/shop/shop_search.dart`](lib/shop/shop_search.dart) |
| "Add to cart": the `cart` event and the kit's toast (there is no cart screen) | `addToShopCart` in [`lib/shop/shop.dart`](lib/shop/shop.dart) |
| Popups from the dashboard | shown by the SDK itself, nothing to set up |

## Running the demo

Requires Flutter 3.41+ (Dart 3.11), Xcode for iOS and Android Studio with the Android SDK.

```sh
flutter pub get
flutter run
```

- Android: the native SDK comes from JitPack, which is already listed in
  [`android/build.gradle.kts`](android/build.gradle.kts).
- iOS: the plugin comes as a Swift package, turned on for this app in
  [`pubspec.yaml`](pubspec.yaml) (`enable-swift-package-manager`), so there is no Podfile. To run
  on a device, replace `DEVELOPMENT_TEAM` in the Xcode project with your own team.

## Configuration

Everything shop-specific is in [`lib/shop_config.dart`](lib/shop_config.dart):

| Constant | What it is |
| --- | --- |
| `shopId` | the shop identifier from your dashboard — replace it with your own |
| `stream` | the analytics stream: the platform (`android` / `ios`) |
| `homePopularCode` | home: "Popular products" |
| `productSimilarCode` | product page: "Similar products" |
| `productRecentlyViewedCode` | product page: "Recently viewed" |
| `storiesCode` | home stories bar; empty — no bar |

The recommender blocks are set up in the dashboard; replace the codes with your own blocks.

"Popular products" of the demo shop runs an A/B test: segment B gets products, segment A an empty
block, which the kit hides. The segment is picked once per install, so on some installs home has no
"Popular products" at all — that is expected.

The demo has no push setup: `autoSendPushToken` is off, and there is no Firebase or APNs
configuration.
