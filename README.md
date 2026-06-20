# whats_new_flutter

**Premium in-app release notes & what's new modal for Flutter.**

Beautiful, animated in-app changelog modal with Material 3 & Cupertino support. Show release notes after app updates with modern transitions.

<video src="doc/screenshots/whats_new_demo.mp4" controls width="320" autoplay loop muted playsinline></video>

## Quick start

```dart
import 'package:whats_new_flutter/whats_new_flutter.dart';

WhatsNewModal.show(
  context,
  config: WhatsNewConfig(
    version: '2.0.0',
    title: "What's New",
    subtitle: 'Welcome to the latest update',
    features: [
      WhatsNewFeatureItem(
        icon: Icons.bolt_rounded,
        title: 'Faster checkout',
        description: 'Complete purchases in fewer steps.',
      ),
      WhatsNewFeatureItem(
        icon: Icons.dark_mode_rounded,
        title: 'Dark mode',
        description: 'Easier on your eyes at night.',
      ),
      WhatsNewFeatureItem(
        icon: Icons.security_rounded,
        title: 'Security boost',
        description: 'Enhanced account protection.',
      ),
    ],
  ),
  theme: WhatsNewTheme.material3(),
);
```

Run the example app:

```bash
cd example
flutter run
```

## Day 1 status

Base modal + animated sheet with blur backdrop, spring slide-up, Material 3 theming, and dark mode support.

## Roadmap

- **Day 2** — Stagger list animations polish
- **Day 3** — Hero header
- **Day 4** — CTA variants
- **Day 5** — JSON support
- **Day 6** — Cupertino polish
- **Day 7** — pub.dev release

## Related

From the creator of [spotlight_tour](https://pub.dev/packages/spotlight_tour) on pub.dev.

## License

MIT © [Umar Anayat](https://github.com/UmarAnayat)
