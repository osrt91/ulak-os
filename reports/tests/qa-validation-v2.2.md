# QA Validation — v2.2.0 Post-Release Sweep

**Run context:** HEAD b0340d6, tag v2.2.0-community, branch main, 2026-04-21
**Scope:** 8-section sweep across 257 templates, 15 commands, 10 skills, 27 agents
**Agent:** qa-validation-commander (single operator, no parallel QA)

---

## Summary

**signoff_status:** blocked

**Rationale:** v2.2.0 is solid on the core dimensions (validator scripts pass, redaction clean, MIT everywhere, anti-pattern SQL triggers correctly enforce AP-EC-02 / AP-MP-01 / AP-REG-01, thin-agent finding-schema YAML conforms). However three P0-class integrity defects in the release surface block a clean ready:

1. **Plugin manifest arithmetic is wrong** — sector_overlays: 17 claimed vs 15 on disk; sector_packs: 24 unsupported by disk evidence (15 concrete overlays exist).
2. **package-lock.json version drift** — still pinned at 2.0.0 while package.json + plugin.json are 2.2.0.
3. **Scaffolder input contract does not cover 40+ placeholders** used in templates (mobile-expo, container-k8s, shared-packages). Any scaffold run with non-trivial input tuple emits unresolved tokens.

**Finding counts:** P0 = 3, P1 = 5, P2 = 4, P3 = 2.
The autonomous-program-director owns the final verdict; this report is the validation input to that decision.
