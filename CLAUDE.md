# GeoAgro Mobile

Flutter mobile app for agricultural plantation management in Uzbekistan.

## Quick Reference

- **Package**: `agro_employee_public`
- **Flutter SDK**: ^3.6.0, Dart SDK ^3.6.0
- **State management**: Riverpod (`flutter_riverpod`)
- **Routing**: go_router
- **API base**: `https://api.geoagro.uz`
- **Backend**: Django REST (pagination, token auth)
- **Maps**: Google Maps Flutter
- **Auth flow**: Phone login → home

## Commands

```bash
flutter pub get          # install deps
flutter analyze          # lint check
flutter test             # run tests
flutter run              # run on connected device
flutter build apk        # build Android APK
```

## Architecture

```
lib/
├── main.dart                      # entry → runner.run()
├── design_system/                 # tokens, components, theme
├── localization/                  # AppStrings (Uzbek-first)
├── dev/                           # dev menu (debug only)
└── src/
    ├── core/
    │   ├── constants/             # app-wide constants
    │   ├── routes/                # GoRouter config, route names
    │   ├── server/
    │   │   ├── api/               # Dio client, API constants, endpoints
    │   │   └── interceptors/      # token, connectivity, logging
    │   ├── services/              # FCM, permissions
    │   ├── setting/               # app bootstrap (setup, runner, remote config)
    │   ├── storage/               # AppStorage (flutter_secure_storage + shared_prefs)
    │   ├── style/                 # legacy colors
    │   ├── tools/                 # formatters
    │   ├── utils/                 # date, marker, network helpers
    │   ├── version/               # version check
    │   └── widgets/               # shared widgets
    ├── data/
    │   ├── model/                 # farmer, fruits, plantation, notification, token, user
    │   └── repository/            # AppRepositoryImpl
    └── feature/
        ├── auth/                  # login
        ├── home/                  # home, approved/pending/recheck lists, notifications
        ├── fermers/               # farmer CRUD, statistics, plantations
        ├── detail_page/           # plantation detail
        ├── edit/                  # plantation edit
        ├── google_map/            # map creation, polygon drawing
        └── profile/               # user profile
```

## Patterns

- **Feature structure**: `feature/<name>/view/{pages,widgets}/ + vm/` (view models as Riverpod providers)
- **API layer**: `ApiConst` for endpoints, `ApiService` (Dio) for HTTP, `AppRepositoryImpl` for data access
- **Global state**: `setup.dart` globals (`accessToken`, `userId`, `districtId`, etc.) initialized at boot
- **Storage**: `AppStorage` wraps secure storage + shared prefs with typed read/write methods
- **Navigation**: `GoRouter` with slide transitions, route names in `AppRouteNames`
- **Remote config**: Firebase Remote Config for feature flags and version control

## Conventions

- Commit messages: mix of English and Russian/Uzbek — keep consistent with existing style
- Localization uses Uzbek as primary language
- `constant_identifier_names` lint suppressed globally
- No iOS target currently — Android only
- GeoJSON files for district boundaries stored in `assets/uzb-geojson/`
