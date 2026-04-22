# Rule Pack — Flutter iOS 2026

Activated when runtime-manifest detects a Flutter project (`pubspec.yaml` with `flutter:` key) that targets iOS primarily (iOS-first product — iOS build config active, Cupertino widgets present, or explicit operator declaration). Sibling to `react-native-expo.md`; applies instead of that pack for Flutter projects.

## Imperatives

### Theme + tokens
- Token-based `ThemeData` — every color, spacing, radius, typography, elevation references a token from `lib/theme/tokens.dart`; zero `Color(0xFF...)` literals in widget code
- Semantic tokens (`surface.elevated`, `text.primary`, `accent.primary`, `status.error`) over raw tokens in widgets; raw palette lives in theme layer only
- `ThemeData.light()` and `ThemeData.dark()` built from the same token set — two render outputs, one source of truth
- Dark mode designed in parallel from commit 1 (see `anti-patterns.md` AP-20); no PR shipped with light-only parity

### Cupertino vs custom
- Use `Cupertino*` widgets when they cover the interaction 1:1 — `CupertinoNavigationBar`, `CupertinoButton`, `CupertinoSwitch`, `CupertinoSegmentedControl`, `CupertinoSearchTextField`, `CupertinoContextMenu`, `CupertinoActionSheet`
- Custom widgets only when Cupertino lacks the need — and then they must feel iOS-native (haptics via `HapticFeedback`, spring-damped physics, SF Symbols / platform-matched iconography)
- NEVER use `Material*` widgets on an iOS-first screen (FloatingActionButton, MaterialRipple, Snackbar) — breaks the visual contract
- Page transitions: `CupertinoPageRoute` as default; no slide-up modal where native push is expected

### Layout + density
- Safe areas respected: `SafeArea` wraps every scroll surface; sticky bottom CTAs use `viewPadding.bottom` not `padding.bottom`
- Touch targets ≥44×44pt (Apple HIG minimum); measured, not eyeballed
- Content horizontal padding matches iOS convention: 16pt (compact) / 20pt (regular) — single constant in tokens, not re-declared per screen
- Line length readable (<70ch for body copy on phone); text doesn't stretch edge-to-edge on tablet — use a `maxContentWidth` constraint

### Components (iOS-first discipline)
- Switches: multi-state capable (on/off/loading), tokens for track + thumb + icon, haptic on state change
- Buttons: explicit loading / success / disabled states in the widget (not stacked widgets); morphing state animation ≤220ms
- Inputs: floating label pattern; inline validation; `TextInputAction.next` chain across form; iOS-style hardware-key handling
- Sheets: `showCupertinoModalPopup` or detented bottom sheet; no full-screen dialog for non-destructive choices
- Lists: `CupertinoListSection.insetGrouped` for settings; `CupertinoListTile` rows; no Material ListTile drift
- Cards: interactive (tap → detail) or action-aware (swipe actions via `Dismissible` + `CupertinoContextMenu`); not just decorative boxes

### Motion
- Duration scale: 100ms (micro), 220ms (standard), 400ms (entrance) — three values, not fourteen
- Curves: `Cupertino.easeInOut` default; `Curves.easeOutBack` for playful; never linear
- Respect `MediaQuery.disableAnimations` (Reduce Motion accessibility setting); static fallback for every transition
- No Lottie / heavy JSON animations on critical paths (startup, list scroll, form submit)

### Accessibility
- Dynamic Type: `MediaQuery.textScaler` respected; no hardcoded font sizes outside the typography scale
- Contrast: WCAG AA min (4.5:1 body, 3:1 large) — enforced by CI screenshot comparison, not prayer
- Semantics: every interactive element has `Semantics(label:, button: true)` or equivalent
- VoiceOver tested on every flow; focus order matches visual reading order

### Performance
- `const` constructors everywhere possible; `const` on leaf widgets measurably rebuilds less
- Images via `cached_network_image` or `Image.network` with explicit `cacheWidth`/`cacheHeight` to physical pixels; no `image.fill` burning GPU
- Lists always `ListView.builder` or `Sliver*`; never `Column` of N widgets inside `SingleChildScrollView`
- Avoid `setState` in ancestor of expensive subtree — lift state to `InheritedWidget` / `Provider` / `Riverpod` at the right granularity

### Code architecture (avoid one-off widget sprawl)
- `lib/design/` — tokens + primitives (AppButton, AppCard, AppSheet, AppListSection)
- `lib/features/<name>/` — per-feature screens + widgets; feature widgets compose from `lib/design/`
- No feature widget re-implements a button, card, or sheet — use the primitive or extend it explicitly
- Shared widgets get promoted to `lib/design/` only after 3+ usage sites (rule of three)

### iOS-specific config
- `ios/Runner/Info.plist`: usage descriptions for every permission requested; empty descriptions rejected by App Store review
- `ios/Runner/PrivacyInfo.xcprivacy` (iOS 17+): declared data collection + usage reasons
- `ios/Podfile`: platform `:ios, '15.0'` minimum (older targets miss Cupertino updates + SwiftUI interop)
- App icon: every required size in `ios/Runner/Assets.xcassets/AppIcon.appiconset/` — no missing sizes (App Store build breaks)
- Launch screen: `LaunchScreen.storyboard` matches first-frame app background; no flash-of-white on cold start

## Collision rule

Project `.claude/rules/flutter.md` or `.claude/rules/ios.md` overrides specific imperatives. When both web (Next.js) and iOS (Flutter) ship as the same product, activate both `typescript-nextjs` (web) and this pack (iOS) — ensure shared brand tokens (color + typography) live in a shared `design-tokens` package consumed by both.

## Integration

- `docs/runtime/anti-patterns.md` — AP-20 (dark-mode-parity), "Android patterns used badly on iOS", "Random one-off widgets"
- `docs/runtime/screen-redesign-template.md` — per-screen redesign checklist used by `/frontend-war-room`
- `.claude/agents/frontend-ios-flutter-director.md` — specialist that applies this pack in Phase 2
- `.claude/agents/design-system-architect.md` — token + primitive governance
- `.claude/agents/educational-ux-specialist.md` — loaded when sector is education / question-solving
