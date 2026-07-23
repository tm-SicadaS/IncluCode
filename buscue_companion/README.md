# BusCue Companion (Flutter)

A Flutter recreation of the BusCue Companion UI: a dark, high-contrast, audio-first
screen for tracking incoming buses at a stop.

## What's included

```
buscue_companion/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── bus.dart
│   ├── theme/
│   │   └── app_colors.dart
│   ├── screens/
│   │   └── home_screen.dart
│   └── widgets/
│       ├── status_pill.dart
│       ├── action_card.dart
│       ├── bus_card.dart
│       └── bottom_nav.dart
```

Only `lib/` and `pubspec.yaml` are included — no `android/`, `ios/`, `web/`
platform folders, since those are best generated fresh by the Flutter CLI on
your machine (they contain machine/OS-specific config).

## How to run it

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) if
   you don't already have it, and make sure `flutter doctor` is happy.
2. Create a fresh Flutter project shell, then drop this `lib/` and
   `pubspec.yaml` into it:

   ```bash
   flutter create buscue_companion
   cd buscue_companion
   # replace the generated lib/ and pubspec.yaml with the ones from this package
   flutter pub get
   flutter run
   ```

   (Or, if you already have a project, just copy `lib/` and merge
   `pubspec.yaml`'s dependencies into yours.)

## Notes on the implementation

- **Colors** live in `lib/theme/app_colors.dart` — tweak the palette there to
  restyle the whole app in one place.
- **`Bus` model** (`lib/models/bus.dart`) holds route, origin/destination, and
  ETA. The three sample buses (47, 12, 5C) are seeded in `home_screen.dart`;
  swap that list for a real data source / API call whenever you're ready.
- **Widgets are split out** (`ActionCard`, `BusCard`, `StatusPill`,
  `BusCueBottomNav`) so they're easy to reuse or restyle independently.
- The speaker icon on each bus card and the three big action buttons currently
  show a snackbar as a placeholder — wire these up to your text-to-speech /
  GPS / notification logic (e.g. the `flutter_tts` and `geolocator` packages
  are natural fits given the app's audio-first, location-based design).
- Bottom nav ("MY STOP" / "SETTINGS") is a simple two-tab switcher; hook up a
  second screen widget when you're ready to build out Settings.
