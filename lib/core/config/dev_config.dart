/// ── DEV BYPASS ───────────────────────────────────────────────────────────
/// When true, the app runs against an in-memory MOCK backend instead of the
/// real API. `flutter run` then needs NO Node, MySQL, or network — products,
/// cart, wishlist, checkout and orders all work locally with bundled images.
///
/// Hardcoded to true so nothing (IDE run configs, leftover --dart-define) can
/// accidentally turn the bypass off while you're testing.
///
/// To use the REAL backend instead, change this single line to:
///   const bool kUseMockBackend = false;
const bool kUseMockBackend = true;
