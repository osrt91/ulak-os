# Analysis Contexts

## Why this exists

A deep audit is incomplete if the director only looks at one dimension. A pure security audit misses UX pain. A pure UX audit misses security holes. A pure performance audit misses observability gaps. This document defines the **minimum set of contexts** that a full program must consider when they are relevant to the project.

Not every context applies to every project. The router decides which are in scope. But the director must not silently skip a context that applies without recording the reason.

## The 28 contexts

For each context, the director's Phase 2 (parallel specialist evidence) and Phase 4 (synthesis) must output:

- **current state** — what the project is today in this dimension
- **evidence** — file:line / URL citations supporting the current-state claim
- **evidence trust** — T1 through T7
- **problem** — what's wrong or missing
- **impact** — who is affected and how
- **risk** — severity + priority
- **recommendation** — concrete action
- **validation** — how to verify the fix
- **owner lane** — which specialist or team owns this

### 1. Product / business
- Primary job-to-be-done
- Business model alignment
- Monetization clarity
- Target segment focus

### 2. User journey / task completion
- Can users complete the primary task without friction?
- Are there dead ends or abandoned states?
- Return-later continuity

### 3. UX / accessibility / readability
- Hierarchy, spacing, motion, readability
- Accessibility (WCAG, VoiceOver, TalkBack)
- Readability of copy and content

### 4. Visual identity / design language
- Coherence across surfaces
- Distinctiveness vs generic AI aesthetic
- Brand alignment

### 5. Information architecture / navigation
- Menu and route structure
- Discoverability
- Back-button / breadcrumb behavior

### 6. Frontend architecture
- Component decomposition
- State management
- Build and bundle health
- Dead code

### 7. Mobile architecture
- Native vs cross-platform split
- Platform-specific guidance (iOS HIG, Android Material)
- Adaptive layout

### 8. Flutter / cross-platform architecture (when applicable)
- Theme / token architecture
- Cupertino vs Material usage
- Plugin ecosystem health

### 9. Backend architecture
- Service decomposition
- Language / runtime alignment
- Deployment topology

### 10. API / contracts / schema
- Contract freshness
- Versioning strategy
- Error handling consistency
- Documentation quality

### 11. Data / persistence
- Schema health
- Migration safety
- Backup / restore
- Query performance

### 12. Security / privacy
- Auth flows
- Authorization / RBAC
- Secrets handling
- Dependency supply chain
- Audit logging

### 13. Customer misuse surface
- Account takeover
- Weak recovery flows
- Data leakage
- Billing exposure
- Privacy settings gaps

### 14. Admin misuse surface
- Privilege escalation
- Broken function authorization (BFLA)
- Unsafe bulk actions
- Export / delete leakage
- Impersonation misuse
- Audit trail gaps

### 15. Open / public API exposure
- Endpoint inventory
- Rate limiting
- Mass assignment
- SSRF / idor / injection
- Schema drift
- Undocumented endpoints

### 16. Infra / DevOps / environments
- Env separation
- Secret management
- IaC hygiene
- Deploy pipeline health
- Rollback readiness

### 17. Performance / scalability / reliability
- N+1 risks
- Caching strategy
- Load-test posture
- SLO definition and monitoring

### 18. Testing / QA
- Test pyramid shape
- Coverage vs critical path
- Flaky test rate
- Integration and contract test presence

### 19. Observability / crash / release health
- Logs, metrics, traces
- Error budgets
- Alerting discipline
- Runbooks

### 20. SEO / ASO / analytics / growth
- Structured data
- Metadata hygiene
- Hreflang
- Analytics event taxonomy
- Experimentation readiness

### 21. Store / distribution / compliance
- Apple App Store readiness
- Google Play readiness
- Privacy policy accuracy
- Legal disclosures
- Store listing truthfulness

### 22. Documentation / DX
- Onboarding ease for new contributors
- ADR hygiene
- README freshness
- Build / test / lint command docs

### 23. Localization / i18n / l10n
- Locale coverage
- Turkish / Unicode normalization (if relevant)
- Surface-level completeness (UI + email + push + legal + store)
- Cultural tone alignment

### 24. Turkish text quality (when Turkish is in scope)
- The six special characters
- ı / i / İ / I handling
- Display vs search vs slug split
- Content quality beyond encoding

### 25. Customer / admin / open API split
- Are the three surfaces actually separated?
- Are permissions correctly scoped per surface?
- Do surfaces share state in ways that leak?

### 26. Support / help / legal
- Help center discoverability
- Support escalation path
- Legal page completeness
- Status page integration

### 27. Pricing / packaging
- Tier clarity
- Paywall UX
- Trial conversion
- Cancellation / refund flow

### 28. Prompt / runtime / pack governance
- CLAUDE.md hygiene
- Command / agent / skill structure
- Hook governance
- MCP governance
- Eval and regression harness presence

## How to use this list

At Phase 2 (parallel specialist dispatch), the director selects which contexts are relevant based on the router decision, the project state, and the surface inventory. Not every context runs every time. But:

- **A full program must at least consider** every context and note the ones that don't apply (with reason).
- **A scoped run** (single-screen, single-endpoint, single-flow) loads only the contexts that touch that scope.
- **Skipping a relevant context silently is a bug.** It must be either analyzed or explicitly recorded as out-of-scope.

## Hard rules

- **Do not claim a context is out of scope without saying why.** "Not relevant" is not enough.
- **Do not collapse two contexts into one.** Customer misuse ≠ admin misuse ≠ open API exposure.
- **Do not skip the prompt/runtime context when working on Ulak OS itself.** Meta-awareness is part of the job.
- **Every context's evidence must have a trust tier.**
- **Findings from context analysis follow `docs/governance/finding-schema.md`.**

## Integration

- `docs/runtime/program-phases.md` — Phase 2 dispatches specialists per context
- `.claude/agents/*.md` — each context maps to at least one specialist
- `docs/runtime/output-profiles.md` — profiles gate which contexts are required
- `docs/runtime/sector-packs.md` — sector packs may add context subtopics
