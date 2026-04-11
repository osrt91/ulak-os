# Golden Prompt 05 — Frontend Rebuild (Flutter / iOS Premium)

## User request

> "Flutter education app'i iOS-first premium 2026 seviyesine getir."

## Expected router decision

```yaml
router:
  task_type: redesign
  active_mode: frontend-war-room
  project_state: brownfield
  intervention_mode: REFACTOR
  scope_level: multi-surface-full-system
  live_research_need: helpful
  artefact_program: full
  output_type: markdown-artifact-set
  output_profile: BROWNFIELD_INTERVENTION_PROFILE
  required_overlays:
    - architecture-currency
    - design-system-rebuild
  required_sector_packs:
    - education
  blocked_paths: []
  validation_depth: standard
  max_parallel_agents: 6
  rationale: "Frontend redesign with iOS-first premium intent on an existing Flutter app. REFACTOR mode (not CREATE) since the app exists. Education sector pack for study-flow context."
```

## Expected active agent map

- cartographer (screen inventory, component inventory)
- frontend-ios-flutter-director (primary)
- design-system-architect
- educational-ux-specialist (study flow, question-solving flow)
- architecture-lead (Flutter architecture sustainability)
- qa-validation-commander (visual regression + accessibility)
- seo-aso-growth-strategist (store listing, ASO)
- release-readiness-auditor (store readiness)

## Must include (assertions)

- Router picks `BROWNFIELD_INTERVENTION_PROFILE` with redesign-specific artefacts
- Active agents include frontend-ios-flutter-director, design-system-architect, educational-ux-specialist
- `reports/current/screen-audit.md` exists — screen-by-screen redesign notes
- Each screen block includes:
  - screen name
  - current issues
  - UX issues
  - hierarchy issues
  - iOS-native issues
  - educational-flow issues
  - component issues
  - new layout structure
  - new interaction model
  - states to support
  - Flutter implementation notes
- `reports/current/design-system.md` exists defining:
  - color tokens
  - typography scale
  - spacing scale
  - radius / border / separator rules
  - shadow / elevation restraint
  - motion rules
  - dark / light parity
  - Flutter theme architecture
- `reports/current/question-flow.md` exists (study flow redesign)
- Red flag detection runs and surfaces any of these if present:
  - generic AI-slop layout
  - random cards / random shadows
  - cheap gradients
  - weak spacing rhythm
  - poor hierarchy
  - bad dark mode parity
  - Android-like patterns badly used on iOS
- Architecture currency labels present on recommendations (CURRENT_RECOMMENDED etc.)
- Implementation order is present and tagged (quick-win / foundational / strategic)
- Store-readiness is checked (App Store + Play compliance for updated assets)

## Must NOT include

- A new screen library recommendation without upstream citation (architecture currency)
- Copying a competitor's visual design wholesale — "inspired by X" must be synthesized
- Gamification suggestions that conflict with the calm/serious brief
- Design system tokens without a Flutter theme architecture note
- A screen redesign without stated implementation order
- "Use Material Design everywhere" on an iOS-first Flutter app

## Validation criteria

- `correct_specialists_active`: frontend-ios-flutter-director + design-system-architect + educational-ux-specialist all run
- `design_system_present`: tokens + scale + rules + Flutter theme
- `screen_by_screen_output`: every audited screen has the full block shape
- `study_flow_redesigned`: question-flow artefact exists
- `red_flag_detection_ran`: explicit scan for the anti-pattern list
- `implementation_order_present`: roadmap has ordered, tagged items
- `store_readiness_checked`: store compliance section present

## Regression signals

- Screen redesign bullets without Flutter implementation notes
- Proposing a new design system without tokens/scale
- Copying inspiration layouts directly
- Missing dark mode parity notes
- Generic "use shadcn/ui" recommendation on a Flutter project (wrong stack)
- Gamification overhaul when the brief is calm + academic
