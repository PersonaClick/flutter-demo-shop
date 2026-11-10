import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:personaclick_sdk/personaclick_sdk.dart';

import 'shop/shop_home.dart';
import 'shop_config.dart';

/// The demo shop: home, categories, product pages and search, built from the UI kit of the
/// PersonaClick SDK and its public methods.
void main() {
  // The SDK talks to the native SDKs over platform channels, which need the binding.
  WidgetsFlutterBinding.ensureInitialized();
  initializeSdk();
  runApp(const ShopApp());
}

/// Initializes the SDK for [shopId], once per launch. The instance is registered, so it is
/// reachable anywhere via `PersonaClick.getInstance(shopId)`; the kit's data widgets find it by
/// the same shop id.
///
/// Popups of the dashboard need nothing more: while no `onPopup` handler is set, the SDK shows
/// them over the app's navigator itself (`enableAutoPopupPresentation` is on by default).
PersonalizationSdk initializeSdk() => PersonaClick.initialize(
  PersonaClickConfig(
    shopId: shopId,
    stream: stream,
    // SDK requests and answers go to the device log of a debug build.
    enableLogs: kDebugMode,
    // The demo has no push setup (no Firebase project, no APNs key): the SDK neither obtains
    // a push token nor sends one.
    autoSendPushToken: false,
  ),
);

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop',
      debugShowCheckedModeBanner: false,
      // Light or dark as the system is; the kit follows the app's theme.
      theme: shopTheme(Brightness.light),
      darkTheme: shopTheme(Brightness.dark),
      home: const ShopPane(shopId: shopId),
    );
  }
}

/// The app's theme on the kit's palette of that [brightness]: its brand is the primary colour,
/// its card the surface, its text colours the text. The roles the kit has no colour for come
/// from its brand colour.
ThemeData shopTheme(Brightness brightness) {
  final colors =
      (brightness == Brightness.dark
              ? PersonalizationTheme.dark
              : PersonalizationTheme.light)
          .colors;
  return ThemeData(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: colors.brandPrimary,
          brightness: brightness,
        ).copyWith(
          primary: colors.brandPrimary,
          onPrimary: colors.textLightPrimary,
          error: colors.semanticDanger,
          surface: colors.backgroundCard,
          onSurface: colors.textPrimary,
          onSurfaceVariant: colors.textSecondary,
          outline: colors.lineGeneric,
          outlineVariant: colors.lineGenericSubtle,
        ),
  );
}
