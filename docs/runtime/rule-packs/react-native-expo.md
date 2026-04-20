# Rule Pack — React Native + Expo

Activated when runtime-manifest detects Expo (`app.json`, `eas.json`) + React Native in the project tree.

## Imperatives

- Expo SDK ≥ 55; React Native ≥ 0.83 (older versions miss Hermes optimizations + New Architecture)
- EAS profiles: explicit `development`, `preview`, `production` in `eas.json` with distinct identifiers
- Shared auth with web: use the same Supabase / auth-provider session; never duplicate auth state client-side
- Deep links: `expo-linking` with prefix registered in `app.json` + server-side `/.well-known/apple-app-site-association` + Android asset link
- Secrets: NEVER in `app.json extra` (bundled into client) — use `eas secret` or runtime-fetched from auth API
- Storage: `expo-secure-store` for tokens (not AsyncStorage); AsyncStorage is plain text on iOS simulator + Android emulator
- Image assets: `expo-image` (not RN Image) for cache + placeholder + blur-hash
- File system writes: `expo-file-system` paths; never hardcode `/var/mobile/...` or `/data/user/...`
- Notifications: `expo-notifications` with server-side push tokens stored per-user-per-device (revocable)
- OTA updates: `expo-updates` in production; pin channel per EAS profile; test update rollback path
- Privacy manifests (iOS 17+): `PrivacyInfo.xcprivacy` in `ios/` declares data collection + usage

## Collision rule

Project `.claude/rules/mobile.md` or `.claude/rules/expo.md` overrides specific imperatives. Products with both web + mobile should also activate `typescript-nextjs` (web) and this pack (mobile).
