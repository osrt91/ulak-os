# Screen Redesign Template

## Why this exists

Frontend redesign ("the app looks outdated / generic / AI-slop") is a recurring ask. Without a structured per-screen template, the redesign drifts into "make it prettier" which is unmeasurable and inconsistent across screens. This template forces every screen through the same questions so the final system feels like one product.

Used by `/frontend-war-room` and `.claude/agents/frontend-ios-flutter-director.md`. Output per screen lands in `reports/current/redesign/<screen-name>.md`.

## When to use

- `/frontend-war-room` dispatches this per screen in Phase 2
- Manual: any time an operator decides a single screen needs redesign (e.g., "leaderboard feels cheap")
- NOT for bug fixes or single-component tweaks — use this only when the *screen as a system* is being re-evaluated

## Per-screen fields (all 15 required — empty field is a finding gap)

### 1. Screen name
Filename-friendly identifier + user-facing label. E.g., `question-solving` → *Question Solving*.

### 2. Current issues
Concrete problems, not adjectives. Not "looks bad" — "CTA font size inconsistent with other screens (16pt here, 17pt in home-dashboard)". File:line if known.

### 3. Why it feels outdated or inconsistent
Root cause, not symptom. Typography drift? Color token not applied? One-off widget re-implemented? Pattern mismatch with rest of app?

### 4. UX issues
Task-completion drift. "User cannot tell which answer is selected after tap", "navigation back target unclear", "no way to mark question for retry without leaving screen". Measured against user goal, not aesthetics.

### 5. Visual hierarchy issues
Size / weight / color relationships that mislead. "Three CTAs with identical visual weight — user can't tell which is primary". "Stats row competes with question body for attention".

### 6. iOS-native feel issues
Android metaphors used on iOS-first app. Material Ripple on a Cupertino screen. FAB where toolbar action belongs. Page slides left where native push expected. Scroll bounce / rubber-band missing. Haptics absent on state change.

### 7. Educational flow issues (if applicable)
For learning apps only: does the screen support focus / momentum / progress visibility / correct-answer trust? Does it break flow (modal where inline works)? Does it interrupt cognitive state?

### 8. Component problems
Which reusable primitives are missing / misused / re-implemented? "This screen has a custom card widget that duplicates `AppCard` with 2px radius drift". Reference `lib/design/` primitive names.

### 9. Color / spacing / typography problems
Specific token drift. "Uses `#3B82F6` hardcoded instead of `color.accent.primary` token". "Horizontal padding 12pt instead of canonical 16pt". "Body text 15pt where scale says 16pt".

### 10. What to redesign
One-line verdict: *redesign layout + hierarchy* / *redesign component usage only* / *redesign interactions only* / *scrap and rebuild from template*.

### 11. New layout structure
Proposed grid / section order / hierarchy. Text diagram or Figma/Sketch link. Describe the *zones* (header / primary content / toolbar / sticky CTA) and their stacking order + safe-area behavior.

### 12. New interaction model
What taps trigger what — including bottom sheets, context menus, long-press, swipe actions. iOS-native patterns only (no Material carryover).

### 13. New component choices
Primitives from `lib/design/` to use. If a new primitive is needed, name it + justify why existing set doesn't cover (rule of three: needed in ≥3 screens before new primitive).

### 14. States to support
Required visual states: loading / empty / error / first-use / success / offline / sync-in-progress / destructive-confirm. Every screen supports the subset that applies — explicit list, not implied.

### 15. Notes for Flutter implementation
Token references, widget choices (Cupertino vs custom), safe-area + keyboard handling, animation durations + curves, accessibility labels + dynamic type. Cross-reference `docs/runtime/rule-packs/flutter-ios-2026.md`.

## Consistency requirements (separate field, applies globally)

Every screen output closes with:

- **Shared primitives used**: list of `lib/design/` widgets consumed — proves this screen doesn't drift
- **Shared tokens used**: list of theme tokens referenced — proves no hardcoded colors / sizes
- **Cross-screen dependencies**: which other screens link here (navigation) and which link *from* here — ensures transitions + state handoff are consistent

## Hard rules

- Do NOT skip fields. Empty field = incomplete redesign audit.
- Do NOT propose a new primitive without the rule-of-three justification.
- Do NOT redesign in isolation — every screen redesign cross-references the design system; if the system doesn't support the need, update the system first and redo this screen against the updated system.
- "Make it prettier" is not a valid Field 10 answer — it must specify *what exactly* is changing and why it improves the product.

## Integration

- `.claude/commands/frontend-war-room.md` — dispatches this template per screen
- `.claude/agents/frontend-ios-flutter-director.md` — applies this template during Phase 2 audit
- `.claude/agents/design-system-architect.md` — enforces primitive + token consistency across screen outputs
- `docs/runtime/rule-packs/flutter-ios-2026.md` — implementation rules referenced from Field 15
- `docs/runtime/anti-patterns.md` — fields 3, 5, 6 reference AP-NN entries for root-cause naming
