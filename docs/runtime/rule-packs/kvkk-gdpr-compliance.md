# Rule Pack — KVKK + GDPR + Multi-Jurisdiction Privacy Compliance

Activated when runtime-manifest detects EITHER (a) `tr` locale in scope (KVKK applies), (b) any EU locale (`de` / `fr` / `es` / `it` / `nl` / `pl` / `pt` / `el` / `cs` / `da` / `fi` / `sv` / `hu` / `ro` / `bg` / `hr` / `sk` / `sl` / `et` / `lv` / `lt`) — GDPR applies, OR (c) any of `ja` / `ko` / `zh` / `ru` / `ar` (jurisdiction-specific regimes apply).

Pattern source: `docs/governance/pattern-import-ledger.md` IL-006 (11-locale multi-jurisdiction QA SaaS, T2 evidence). Sibling to `multi-locale-eleven-rtl.md` (technical i18n contract) — this pack is the privacy-regime contract.

## Imperatives

### Jurisdiction-regime matrix (canonical)

| Locale(s) | Regime | Source | Key requirement |
|---|---|---|---|
| `tr` (Turkey) | **KVKK** (Law 6698) | KVKK 2016 | Aydınlatma metni (TR), VERBİS registry (>50 emp / >25M TRY), 30-day DSR response, explicit consent for sensitive data, processor contracts in Turkish |
| `de` `fr` `es` `it` `nl` `pl` `pt` (+ all EU) | **GDPR** (2016/679) | EU 2018 | Privacy notice (per-language), DPO required (>250 emp OR core monitoring), 72h breach notification, 30-day DSR response, lawful basis declared, DPIA for high-risk processing, EU representative if non-EU controller |
| `en` (UK) | **UK GDPR + DPA 2018** | UK 2021 | Same as GDPR + ICO registration fee + UK representative if outside UK |
| `en` (US — California) | **CCPA / CPRA** | CA 2020/2023 | Right to know + delete + opt-out of sale + correct + limit; CPRA adds sensitive PI category; "Do Not Sell or Share" link required on homepage |
| `ja` (Japan) | **APPI** (改正個人情報保護法) | 2022 amend | Re-identification ban, cross-border transfer notice (purpose + recipient country listed), consent for sensitive data, opt-out for third-party transfer |
| `ko` (Korea) | **PIPA** (개인정보 보호법) | 2011, 2023 amend | DPO mandatory (all data controllers), Korean-language notice, 5-year breach record, consent for resident registration number processing (heavily restricted) |
| `zh` (China — mainland) | **PIPL** + **DSL** + **CSL** | PIPL 2021 | Data localization (PII of >1M users stays in China), security assessment for cross-border transfer >100K subjects, separate consent per processing purpose, Chinese-language notice |
| `ru` (Russia) | **152-FZ** | 2006, 2014 amend | **Mandatory data residency** (PII of Russian citizens stored on servers physically in Russia, registered with Roskomnadzor) — non-compliance = blocking by Russian ISPs |
| `ar` (KSA) | **PDPL** (Saudi) | 2023 | Data localization preference, Arabic-language notice, DPO for high-risk, 72h breach notification, transfer restrictions |
| `ar` (UAE) | **PDPL** (UAE Federal Decree-Law 45/2021) | 2022 | Consent, data subject rights similar to GDPR, no DPO requirement, 6-month transition windows |
| `pt` (Brazil) | **LGPD** | 2020 | Portuguese privacy notice, DPO required, 9 lawful bases, ANPD reporting |

A locale shipped without its corresponding regime mapped = compliance miss. The matrix lives in code (`config/privacy-regimes.ts` or `app/privacy/regimes.py`) and drives runtime behavior, not just documentation.

### Privacy notice (Aydınlatma metni / Privacy Policy / 隐私政策)

- Per-locale, written / reviewed by a native speaker — machine-translated privacy text is a regulator-tier risk
- Per-jurisdiction wording differences enforced (KVKK requires "veri sorumlusu" + VERBİS reference; GDPR requires "controller" + DPO contact; PIPL requires Chinese-language version + processing purpose enumeration)
- Versioned: every change creates a new `effective_date` + diff page; users notified via email when material change ships
- Linked from: footer (every page), registration form, payment flow, account settings, every email footer
- HTML `<link rel="alternate" hreflang="...">` tags so search engines surface the locale-specific notice

### Cookie consent

- **EU/UK locales**: opt-in, granular categories (necessary / functional / analytics / marketing), TCF v2.2 vendor list if using ad tech, withdraw consent ≥ as easy as give consent
- **US (California)**: "Do Not Sell or Share" link required, opt-out (not opt-in by default) — but increasingly states (CO, CT, VA, UT) require GDPR-style consent
- **TR (KVKK)**: consent banner not strictly required for non-marketing cookies, BUT marketing cookies require explicit consent + KVKK-language notice
- **Japan (APPI)**: opt-in for cross-border transfers + sensitive personal data
- **China (PIPL)**: separate consent per purpose — analytics, marketing, third-party share each need their own consent toggle
- A single global "Accept all" banner without per-region branching = non-compliant in EU + China + Korea simultaneously
- Server-side enforcement: cookie set ONLY after server confirms consent record exists for that user/IP; never `<script src=analytics>` rendered before consent check

### Data Subject Rights (DSR) endpoints

A regulated multi-jurisdiction product MUST expose:

- **Right to access** (export user's data) — JSON + CSV, all PII fields, within 30 days (KVKK/GDPR/CCPA), 30 days extendable (CCPA), 15 days (PIPA Korea)
- **Right to rectification** — UI for user to edit profile + admin endpoint for non-self-serviceable fields
- **Right to erasure** ("right to be forgotten") — soft-delete + 30-day grace + hard-delete cascading FK; backups overwritten on next rotation cycle
- **Right to restriction** — flag the user record so processing pauses but data not deleted (legal hold scenarios)
- **Right to portability** — machine-readable export (JSON), excludes derived analytics
- **Right to object** — opt-out of marketing + profiling
- **Right to withdraw consent** — same UX as giving consent

Endpoints documented in privacy notice with response SLA per jurisdiction. Audit log every DSR action (who/when/which records affected) — retain ≥ jurisdiction maximum (5 years PIPA Korea is the longest).

### Data retention matrix

A retention schedule MUST exist as a code artefact, not a wiki page:

```yaml
# config/data-retention.yaml
user_account: { active: indefinite, deleted: 30d_soft + immediate_hard }
session_logs: { retention: 90d, jurisdictions: { ru: 6mo_local, zh: 6mo_local } }
payment_records: { retention: 10y_TR, 7y_EU_tax, 7y_US_IRS }
audit_log_authn: { retention: 5y_PIPA_KR, 2y_KVKK_TR, 2y_GDPR_baseline }
audit_log_dsr: { retention: 5y_PIPA_KR, 3y_GDPR }
analytics_event: { retention: 26mo_EU_GA, 14mo_consent_default }
chat_messages: { retention: 1y_default, opt_in_extension: 3y }
geolocation: { retention: 30d, opt_in_extension: 1y }
```

Cron job purges data that exceeds its retention; deletion is logged.

### Cross-border transfer governance

- Every data flow that crosses a jurisdiction border has a recorded **lawful transfer mechanism**: SCCs (EU→ROW), adequacy decision (EU→UK / EU→JP / EU→KR), explicit consent (jurisdiction-specific), DPF for US (post-Schrems II)
- Russia: PII of Russian citizens MUST stay on Russian-located servers; cross-border copy requires Roskomnadzor registration
- China: PIPL security assessment for >100K subjects' PII leaving China — government approval, not self-cert
- Provider list (Vercel, Supabase, Stripe, AWS, Resend, etc.) has per-region presence — pick the correct region per user's jurisdiction or document the legal basis for cross-region

### DPO + representative

- EU controllers: DPO if (a) public authority, (b) core activities = regular monitoring of data subjects on a large scale, OR (c) core activities = large-scale processing of special category data
- Non-EU controllers offering goods/services to EU residents: appoint EU representative (Article 27)
- KVKK: data controller representative if foreign company (mandatory KVKK registration)
- China (PIPL): designated representative in China for foreign controllers
- Korea: PIPA requires DPO regardless of size for personal data controllers
- Contact info published in privacy notice + at `/.well-known/dpo` JSON manifest

### Processor (sub-processor) chain

- List every processor (cloud host, email, SMS, payment, analytics, error tracking) per jurisdiction
- DPA (Data Processing Agreement) signed with each, in writing — processor's DPA references controller's Standard Contractual Clauses if cross-border
- Sub-processor changes require advance notice to data subjects (GDPR + KVKK + LGPD)
- Sub-processor list published at `/legal/subprocessors` (or equivalent), updated on every change

### Sensitive data (special category)

- Health, biometric, racial/ethnic, political, religious, sexual orientation, criminal record, trade union — explicit consent required across nearly all regimes
- Children's data: under 13 (COPPA US), under 16 (GDPR default, member state may lower to 13), under 14 (KR), under 14 (PIPL CN), under 18 (Brazil LGPD) — age-gate + parental consent flow per jurisdiction
- Korean Resident Registration Number: heavily restricted, alternative verification (CI/DI tokens) required for most use cases
- Indian Aadhaar: cannot be processed without UIDAI license (most products should NOT collect)

### Encryption + access controls

- PII encrypted at rest (Postgres TDE, S3 SSE-KMS) — required by GDPR Art. 32, KVKK Art. 12, PIPL Art. 51
- PII encrypted in transit (TLS 1.3) — TLS 1.0/1.1 disabled; TLS 1.2 with cipher suite restrictions
- Access logging for PII tables — who/when/which row, retained per audit retention matrix
- Production secrets (API keys, DB credentials) never in source — `.env.local` gitignored (`anti-patterns.md` AP-16) + secret rotation cadence
- Backups encrypted + access-restricted; restore drills quarterly (`anti-patterns.md` AP-17)

### Breach notification

- 72-hour notification to supervisory authority (GDPR/KVKK/KSA-PDPL/UAE-PDPL/PIPL/PDPL Brazil)
- Affected users notified "without undue delay" (GDPR), 5 days (KVKK), without delay (PIPA Korea), 24h (Vietnam PDPD)
- Pre-drafted templates per locale per regime — incident response runbook references them
- Audit log of breach decision (was notification triggered? rationale?) retained 5+ years
- Insurance: cyber liability policy reviewed annually for jurisdiction coverage gaps

## Validator rules (CI-blocking)

- `scripts/validate-privacy-notice-coverage.sh` — every locale in `SUPPORTED_LOCALES` has a non-empty privacy notice file at `docs/legal/privacy/<locale>.md` AND `effective_date` field present
- `scripts/validate-retention-config.sh` — `config/data-retention.yaml` parses, every PII table referenced, no `retention: indefinite` for non-account tables
- `scripts/validate-dsr-endpoints.sh` — required endpoints (`/api/dsr/access`, `/api/dsr/export`, `/api/dsr/delete`, `/api/dsr/rectify`) exist + have rate limiting + auth
- `scripts/validate-cookie-consent.sh` — no analytics / marketing scripts loaded before consent endpoint returns positive

## Collision rule

Project `.claude/rules/privacy-jurisdiction.md` overrides specific imperatives (e.g., a TR-only product doesn't need PIPL section); unmatched inherit. The jurisdiction matrix itself is a load-bearing immutable — a project removing entries from the matrix without locale-removal evidence is a finding.

## Integration

- `docs/runtime/rule-packs/multi-locale-eleven-rtl.md` — sibling pack (technical i18n contract)
- `docs/runtime/rule-packs/turkish-locale.md` — KVKK-specific TR character + collation rules
- `docs/runtime/sector-packs.md §regulated-saas` — sector-level bundle when regulated industry layered atop privacy regime
- `docs/governance/secrets-rotation-policy.md` — encryption-key rotation cadence
- `docs/runtime/anti-patterns.md` — AP-16 (.env.local committed), AP-17 (no DB backup) intersect with GDPR Art. 32
- `docs/governance/pattern-import-ledger.md` — IL-006 source provenance
- `.claude/agents/privacy-compliance-counsel.md` — the agent that audits this pack

## Canonical footer

Authoritative as of Ulak OS **v1.7.0**. Imported from an 11-locale multi-jurisdiction security/QA scanner SaaS operating under TR-KVKK + EU-GDPR + JA-APPI + KR-PIPA + ZH-PIPL + RU-152-FZ + KSA-PDPL simultaneously. The 11-locale × 7-regime cross-product is the load-bearing contribution; single-jurisdiction projects load only the matching subset.
