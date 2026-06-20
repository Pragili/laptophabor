# LaptopHarbor

A cross-platform laptop e-commerce application — **Flutter (Riverpod)** front end + **Node.js / Express / Sequelize / MySQL** REST API with a mock payment gateway and an admin module.

This is the Phase 2 implementation of the design delivered in `LaptopHarbor_Phase1.md`.

---

## Architecture

```
laptopharbor/
├── backend/      Node + Express + Sequelize REST API (MySQL)
└── frontend/     Flutter app (feature-first + Riverpod state management)
```

- **State management:** Riverpod with hand-written providers (no `build_runner`/codegen), so the app runs with a plain `flutter run`.
- **Layering (per feature):** `domain/` (models) → `data/` (repositories that call the API via Dio) → `presentation/` (Riverpod notifiers/providers + screens). Widgets never talk to Dio or storage directly.
- **Auth:** JWT issued by the API, stored in `flutter_secure_storage`, attached to every request by a Dio interceptor. Session is restored on launch.
- **Routing:** `go_router` with a redirect guard (unauthenticated → login; non-admin → home for `/admin`) and a `ShellRoute` bottom-nav for the 5 primary tabs.

---

## macOS desktop

The app runs as a native macOS desktop app. Requirements: **macOS with Xcode** and **CocoaPods** (`brew install cocoapods` or `sudo gem install cocoapods`).

```bash
cd frontend
./setup.sh                 # generates macos/ (and the other platforms) + entitlements
flutter run -d macos
```

**Network entitlement (important).** macOS sandboxes apps and blocks all network access unless the `com.apple.security.network.client` entitlement is set — this affects both the real API and the Inter web font. The repo ships `macos/Runner/DebugProfile.entitlements` and `Release.entitlements` with it already enabled, and `setup.sh` re-applies it if Flutter regenerates those files. If you scaffold manually with `flutter create`, add this key to both files yourself.

**Real backend over HTTP (dev only).** Demo mode works offline. To point macOS at the real API over `http://localhost`, App Transport Security needs a local-networking exception:

```bash
/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity dict" macos/Runner/Info.plist 2>/dev/null
/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsLocalNetworking bool true" macos/Runner/Info.plist 2>/dev/null
flutter run -d macos --dart-define=MOCK=false --dart-define=API_URL=http://localhost:4000/api
```

(Or point `API_URL` at an `https` endpoint and skip the ATS change.)

---

## Quick start — test with NO backend (dev bypass)

Want to click through the app immediately, without Node, MySQL or any server? A mock-backend mode is built in and **on by default**:

```bash
cd frontend
flutter pub get
flutter run -d chrome      # runs in the browser — no native setup needed
```

The repo ships with the **web runner** already generated (`web/`), so the line above
works immediately. For an **Android/iOS** device or emulator, generate the native
runners once (see “Platform scaffolding” below), then `flutter run`.

Everything works from in-memory data — the 12 laptops (with their bundled images), search, filters, product details, cart, wishlist, checkout, orders, notifications, FAQ and the admin dashboard. Cart/wishlist/orders update for the session. A small amber **DEMO** ribbon shows in the corner while the bypass is active. Log in with anything (the screen is prefilled), or just tap **Log In**.

The switch lives in `lib/core/config/dev_config.dart`. To run against the **real** API instead:

```bash
flutter run --dart-define=MOCK=false      # or set kUseMockBackend = false
```

Implementation: `lib/core/network/mock_interceptor.dart` is a Dio interceptor that short-circuits requests with canned responses (data in `mock_data.dart`). Because it sits at the Dio layer, none of the repositories, providers or screens change between mock and real mode.

---

## Platform scaffolding (android / ios / desktop)

To keep the download lean, this project includes the cross-platform code (`lib/`, `pubspec.yaml`, `test/`) and the **web** runner, but not the generated `android/`, `ios/`, `windows/`, `macos/`, `linux/` folders. Generate them in one step — it wraps the existing code without touching `lib/` or `pubspec.yaml`:

```bash
cd frontend
./setup.sh            # macOS / Linux   (setup.bat on Windows)
# — or directly —
flutter create . --org com.laptopharbor --platforms=android,ios,web,windows,macos,linux
flutter pub get
```

Then run on any target:

```bash
flutter run -d chrome      # web (browser)
flutter run                # connected device / emulator
flutter test               # runs the smoke tests
```

> `flutter create .` is safe to run on an existing project: it only adds the missing platform files and leaves your `lib/`, `pubspec.yaml`, `web/` and tests intact.

---

## 1. Backend setup

Requirements: **Node 18+** and a running **MySQL 8** server.

```bash
cd backend
npm install

# configure environment
cp .env.example .env
#   then edit .env -> set DB_USER / DB_PASS / DB_NAME and a JWT_SECRET

# create an empty database named in DB_NAME, e.g. in MySQL:
#   CREATE DATABASE laptopharbor;

# seed brands, categories, 12 sample laptops, FAQs and demo users
npm run seed

# start the API (http://localhost:4000)
npm run dev
```

Health check: `GET http://localhost:4000/api/health`

### Demo accounts (created by the seed)
| Role     | Email                      | Password   |
|----------|----------------------------|------------|
| Admin    | `admin@laptopharbor.com`   | `admin123` |
| Customer | `ada@example.com`          | `user123`  |

### Key endpoints
- `POST /api/auth/register` · `POST /api/auth/login` · `GET /api/auth/me`
- `GET /api/products` (filters: `q, categoryId, brandId, minPrice, maxPrice, ram, storage, cpu, minRating, sort, page`)
- `GET /api/products/featured` · `GET /api/products/:id` · `GET /api/categories` · `GET /api/brands`
- `GET/POST/PUT/DELETE /api/cart` · `GET/POST /api/wishlist/toggle`
- `POST /api/orders/checkout` (mock payment) · `GET /api/orders` · `GET /api/orders/:id`
- `POST /api/reviews` (+ update/delete) · `GET /api/faqs` · `POST /api/contact`
- `GET /api/notifications` · `GET/POST/DELETE /api/addresses`
- Admin (`requireRole('admin')`): `/api/admin/dashboard`, `/api/admin/products`, `/api/admin/orders`, `/api/admin/users`

---

## 2. Frontend setup

Requirements: **Flutter 3.3+**.

```bash
cd frontend
flutter pub get
flutter run
```

### Pointing the app at your API
`lib/core/config/env.dart` defaults to `http://10.0.2.2:4000/api`:

- **Android emulator** → `10.0.2.2` already maps to your host machine. No change needed.
- **iOS simulator / web / desktop** → change `defaultValue` to `http://localhost:4000/api`.
- **Physical device** → use your computer's LAN IP, e.g. `http://192.168.1.20:4000/api`.

Or override at run time without editing code:

```bash
flutter run --dart-define=API_URL=http://192.168.1.20:4000/api
```

> Note: `google_fonts` fetches the Inter font at runtime on first launch, so the device needs internet access (the same network used to reach the API is fine). To ship fully offline, bundle the Inter `.ttf` files and switch `app_typography.dart` to a bundled `TextTheme`.

---

## 3. Product imagery

The 12 seeded laptops ship with original flat-illustration images (3 gallery shots each, 36 PNGs in `backend/src/uploads/`), generated offline with Pillow — no stock photos or external image services. Each is tinted by category (neon gaming, silver ultrabooks, matte business) and labelled with brand + model.

Image paths are stored **relative** (e.g. `/uploads/laptop-0.png`); the Flutter app resolves them against its API host via `lib/core/utils/image_url.dart`, so they load correctly on the emulator, a physical device, or web without per-environment URL edits.

Regenerate or restyle them anytime:

```bash
python3 generate_laptops.py        # needs Python 3 + Pillow
```

To use real product photos instead, drop your own files into `backend/src/uploads/` and point the seed (`backend/src/utils/seed.js`) at them.

## 4. What's implemented

**Backend — complete:** auth (+ forgot/reset), product catalog with full filtering, cart, wishlist, transactional checkout with stock decrement + tax/shipping, reviews with denormalised rating recompute, notifications, addresses, FAQ/contact, and the admin module (dashboard metrics, product CRUD with image upload, order lifecycle, user roles). Every file passes `node --check`.

**Frontend — core shopping flow wired end-to-end:** splash + session restore, login / register / forgot-password, home (featured + categories + search entry + promo), product listing (sort + filter drawer: brand / price range / RAM / storage / rating), product details (image gallery, specs, reviews, sticky add-to-cart), debounced search, cart (quantity stepper + live totals), 3-step checkout (address → payment → review → success), wishlist, orders list with status pills, notifications, FAQ, profile (+ logout), an admin dashboard, and the bottom-nav shell with a live cart badge.

The Flutter code is written against Flutter 3.3+ stable but has **not** been run through `dart analyze` in this environment (no SDK available here), so budget a little time for minor version-specific lint/API nits on first build.

---

## 5. Suggested next steps
- Wire the wishlist heart onto catalog/home product cards (provider + repository already exist).
- Avatar upload on the profile screen (`image_picker` is already a dependency).
- Admin product-management and order-status screens (the API endpoints are ready).
- Order detail / live tracking timeline screen (the `GET /api/orders/:id` endpoint is ready).
