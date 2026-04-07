#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MASTER V10.3 — Autonomous Program Director
One-file bootstrap generator.

Usage:
  python master_v10_3_autonomous_program_director_onefile.py
  python master_v10_3_autonomous_program_director_onefile.py --out ./my-pack --zip
  python master_v10_3_autonomous_program_director_onefile.py --in-place --force --project-name "My Product"
"""
from __future__ import annotations
import argparse, json, shutil
from pathlib import Path
from textwrap import dedent

VERSION = "10.3"
DEFAULT_OUT = "v10_3_autonomous_program_director"

AGENTS = json.loads(r"""[
  [
    "autonomous-program-director",
    "Executive manager for full, complete, rescue, greenfield, brownfield, or hybrid programs. Routes work, activates specialists, kills menu loops, enforces artefacts, and returns one merged verdict.",
    "Read, Grep, Glob, Bash, Edit, Write",
    [
      "route the request into the correct intervention mode",
      "start work without repeating scope menus when intent is already clear",
      "decide which specialist agents must be activated",
      "merge conflicts and choose one final path",
      "force artefact creation under reports/current",
      "end with verdict, residual risks, and next execution lane"
    ],
    [
      "runtime decision",
      "active agent map",
      "phase status",
      "manager verdict",
      "residual risks"
    ]
  ],
  [
    "cartographer",
    "System cartographer for repo, routes, screens, endpoints, configs, dependencies, and evidence gaps.",
    "Read, Grep, Glob, Bash",
    [
      "map files and folders",
      "inventory routes, screens, endpoints, and configs",
      "separate customer, admin, and public API surfaces",
      "identify evidence gaps before assumptions spread"
    ],
    [
      "inventory",
      "surface map",
      "evidence gaps"
    ]
  ],
  [
    "product-business-strategist",
    "Product and business strategist for goals, user segments, value flow, pricing logic, and rollout priority.",
    "Read, Grep, Glob",
    [
      "clarify product goal and value proposition",
      "identify user segments and task completion paths",
      "check pricing, package, and monetization clarity"
    ],
    [
      "product framing",
      "business risks",
      "priority suggestions"
    ]
  ],
  [
    "market-researcher",
    "Market researcher for competitors, pricing, positioning, language opportunities, and category expectations.",
    "Read, Grep, Glob, Bash",
    [
      "collect comparable products and positioning signals",
      "flag weak market evidence",
      "identify locale and language opportunities"
    ],
    [
      "research notes",
      "competitor matrix",
      "market gaps"
    ]
  ],
  [
    "architecture-lead",
    "Principal architect for target architecture, modularity, migration, and maintainability.",
    "Read, Grep, Glob, Bash",
    [
      "assess architectural maturity",
      "propose target architecture and migration path",
      "avoid big bang rewrites unless strictly justified"
    ],
    [
      "architecture findings",
      "target architecture",
      "migration guidance"
    ]
  ],
  [
    "frontend-ios-flutter-director",
    "Specialist for premium iOS-first Flutter/mobile frontend redesign and coherence.",
    "Read, Grep, Glob",
    [
      "inspect visual hierarchy and interaction quality",
      "enforce 2026 premium mobile bar",
      "produce screen-by-screen redesign logic"
    ],
    [
      "frontend findings",
      "design direction",
      "implementation order"
    ]
  ],
  [
    "design-system-architect",
    "Design system specialist for tokens, spacing, typography, color, surfaces, and reusable components.",
    "Read, Grep, Glob",
    [
      "normalize design tokens",
      "spot component drift and one-off styling",
      "define reusable system rules"
    ],
    [
      "token plan",
      "component standards",
      "drift findings"
    ]
  ],
  [
    "educational-ux-specialist",
    "Education/question-flow UX specialist for study continuity, motivation, clarity, and explanation quality.",
    "Read, Grep, Glob",
    [
      "review question-solving flow",
      "check explanation, retry, and confidence building",
      "reduce cognitive fatigue without clutter"
    ],
    [
      "education UX findings",
      "flow gaps",
      "redesign notes"
    ]
  ],
  [
    "backend-api-architect",
    "Backend and API specialist for contracts, error handling, endpoint design, and integration safety.",
    "Read, Grep, Glob, Bash",
    [
      "inventory endpoint shapes and contracts",
      "flag schema drift and undocumented behaviors",
      "separate public and authenticated API risks"
    ],
    [
      "api findings",
      "contract issues",
      "backend recommendations"
    ]
  ],
  [
    "data-database-governor",
    "Data and database specialist for schema, migrations, integrity, and query risk.",
    "Read, Grep, Glob, Bash",
    [
      "review data model and migration safety",
      "flag stale schema assumptions",
      "identify data consistency risks"
    ],
    [
      "data findings",
      "migration risks",
      "schema notes"
    ]
  ],
  [
    "infra-release-sre",
    "Infra/SRE specialist for CI/CD, rollback, release health, observability, and runtime resilience.",
    "Read, Grep, Glob, Bash",
    [
      "review deployment, rollback, and release safety",
      "check logging, metrics, traces, and runbooks",
      "identify release blockers and blind spots"
    ],
    [
      "release findings",
      "observability gaps",
      "rollback guidance"
    ]
  ],
  [
    "security-hardening-lead",
    "Security specialist for auth, authorization, admin/customer/public API separation, abuse, and secrets.",
    "Read, Grep, Glob, Bash",
    [
      "check auth and permission boundaries",
      "flag BOLA/BFLA/admin misuse risks",
      "review secret handling and abuse prevention"
    ],
    [
      "security findings",
      "severity map",
      "hardening recommendations"
    ]
  ],
  [
    "qa-validation-commander",
    "QA lead for test matrix, validation gates, regression strategy, and final completion discipline.",
    "Read, Grep, Glob, Bash",
    [
      "define validation plan",
      "split customer, admin, and open-API tests",
      "refuse done-claims without test evidence"
    ],
    [
      "validation plan",
      "test matrix",
      "completion risks"
    ]
  ],
  [
    "prompt-skill-plugin-governor",
    "Specialist for commands, agents, skills, hooks, MCP, plugin decisions, and pack-gap control.",
    "Read, Grep, Glob, Bash, Edit, Write",
    [
      "decide when to create a command, skill, agent, hook, MCP, or plugin",
      "track missing reusable units as pack gaps",
      "keep the pack modular and forward-only"
    ],
    [
      "pack-gap register",
      "reusable-unit recommendations",
      "governance notes"
    ]
  ],
  [
    "localization-i18n-lead",
    "Specialist for i18n, l10n, Turkish characters, locale-aware casing, text expansion, and store localization.",
    "Read, Grep, Glob",
    [
      "check Turkish characters and locale-aware casing",
      "review multi-language risk and text expansion",
      "separate storage/search normalization from display text"
    ],
    [
      "i18n findings",
      "localization risks",
      "language map"
    ]
  ],
  [
    "seo-aso-growth-strategist",
    "SEO, ASO, analytics, experimentation, and growth systems specialist.",
    "Read, Grep, Glob",
    [
      "review SEO/ASO basics and discoverability",
      "check analytics taxonomy and experimentation readiness",
      "identify conversion leaks"
    ],
    [
      "growth findings",
      "SEO/ASO notes",
      "analytics gaps"
    ]
  ],
  [
    "privacy-compliance-counsel",
    "Privacy and compliance reviewer for data minimization, disclosures, retention, and sensitive-surface clarity.",
    "Read, Grep, Glob",
    [
      "review privacy posture and consent surfaces",
      "flag retention/delete/export gaps",
      "identify sensitive-data handling risks"
    ],
    [
      "privacy findings",
      "compliance gaps",
      "disclosure notes"
    ]
  ],
  [
    "support-ops-orchestrator",
    "Support and operations specialist for help flows, moderation/support tooling, and issue deflection quality.",
    "Read, Grep, Glob",
    [
      "review help and support entry points",
      "check operational handoff quality",
      "flag support load amplifiers"
    ],
    [
      "support findings",
      "ops notes",
      "handoff gaps"
    ]
  ],
  [
    "release-readiness-auditor",
    "Release readiness reviewer for store/distribution/launch quality and final launch blockers.",
    "Read, Grep, Glob, Bash",
    [
      "check release gates and launch completeness",
      "review app/store/distribution readiness",
      "flag last-mile blockers"
    ],
    [
      "release verdict input",
      "launch blockers",
      "go-live notes"
    ]
  ],
  [
    "red-team-challenger",
    "Adversarial reviewer that challenges the current plan and tries to break weak assumptions.",
    "Read, Grep, Glob",
    [
      "attack weak assumptions and shallow evidence",
      "identify contradiction and blind spots",
      "propose stronger alternatives when necessary"
    ],
    [
      "objections",
      "blind spots",
      "strengthened plan"
    ]
  ]
]""")
COMMANDS = json.loads(r"""{
  "director.md": "---\ndescription: Run the Autonomous Program Director. Use for complete, end-to-end, rescue, greenfield, brownfield, or \"komple\" requests. The director must auto-route, create artefacts immediately, activate the needed specialists, and finish with one manager verdict.\n---\n\nUse the autonomous-program-director subagent and this pack's runtime docs.\n\nDo not ask repeating scope menus when intent is clear.\n\nStart by creating or updating:\n\n- reports/current/runtime-manifest.md\n- reports/current/assumptions.md\n- reports/current/inventory.md\n- reports/current/pack-gap-register.md\n\nARGUMENTS:\n$ARGUMENTS\n",
  "intake.md": "---\ndescription: Run project intake and inventory first. Use when the project needs to be read before deeper work starts.\n---\n\nUse the cartographer and project-intake skill.\n\nCreate or update:\n\n- reports/current/intake.md\n- reports/current/inventory.md\n- reports/current/evidence-register.md\n\nARGUMENTS:\n$ARGUMENTS\n",
  "frontend-war-room.md": "---\ndescription: Run the frontend/mobile war room for premium redesign, visual system cleanup, and implementation ordering.\n---\n\nUse:\n- frontend-ios-flutter-director\n- design-system-architect\n- educational-ux-specialist\n\nCreate or update:\n- reports/current/analysis-findings.md\n- reports/current/target-state.md\n- reports/current/execution-roadmap.md\n\nARGUMENTS:\n$ARGUMENTS\n",
  "pack-gap-audit.md": "---\ndescription: Inspect the current operating pack and list missing commands, skills, agents, hooks, MCP connectors, docs, and eval coverage.\n---\n\nUse the prompt-skill-plugin-governor.\n\nCreate or update:\n- reports/current/pack-gap-register.md\n- reports/current/manager-verdict.md\n\nARGUMENTS:\n$ARGUMENTS\n",
  "final-verdict.md": "---\ndescription: Run final validation, challenge assumptions, and produce the single merged manager verdict.\n---\n\nUse:\n- qa-validation-commander\n- release-readiness-auditor\n- red-team-challenger\n- autonomous-program-director\n\nCreate or update:\n- reports/current/validation-plan.md\n- reports/current/manager-verdict.md\n\nARGUMENTS:\n$ARGUMENTS\n"
}""")
SKILLS = json.loads(r"""{
  "project-intake": "---\nname: project-intake\ndescription: intake, inventory, and evidence-gathering workflow for full audits, rescue programs, or when the user wants the system to read the whole project before acting.\ncontext: fork\nagent: cartographer\nallowed-tools: Read Grep Glob Bash(find *) Bash(ls *) Bash(cat *) Bash(tree *)\n---\n\n# Project Intake\n\nUse this custom skill pack when the project needs to be mapped before deeper work.\n\n## Required outputs\n- reports/current/runtime-manifest.md\n- reports/current/assumptions.md\n- reports/current/intake.md\n- reports/current/inventory.md\n- reports/current/evidence-register.md\n\n## Rules\n1. Split customer, admin, and public API surfaces.\n2. Record missing evidence instead of guessing.\n3. Start artefacts immediately when intent is clear.\n",
  "research-currency": "---\nname: research-currency\ndescription: research and currency check workflow for market signals, competitor positioning, language opportunities, and whether the proposed stack or UX is below the 2026 bar.\ncontext: fork\nagent: market-researcher\nallowed-tools: Read Grep Glob Bash\n---\n\n# Research Currency\n\n## Goal\nDetermine whether the current plan is supported by sufficiently strong evidence and whether it is current enough for a 2026-grade recommendation.\n\n## Outputs\n- reports/current/research-notes.md\n- reports/current/analysis-findings.md\n\n## Rules\n- Distinguish strong evidence from weak signals.\n- Say when evidence is too weak.\n- Escalate stale architecture or below-bar UX clearly.\n",
  "pack-gap-completion": "---\nname: pack-gap-completion\ndescription: detect and explain missing reusable units such as commands, skills, agents, hooks, MCP connectors, docs, or evals when the project needs stronger automation and reuse.\ncontext: fork\nagent: prompt-skill-plugin-governor\nallowed-tools: Read Grep Glob Bash Edit Write\n---\n\n# Pack Gap Completion\n\n## Goal\nExplain what reusable unit is missing and where it should live.\n\n## Outputs\n- reports/current/pack-gap-register.md\n- reports/current/execution-roadmap.md\n\n## Rules\n- Prefer the smallest reusable unit that solves repetition.\n- Convert recurring workflow pain into commands, skills, agents, hooks, or MCP recommendations.\n- Do not leave reusable-unit gaps vague.\n",
  "final-validation": "---\nname: final-validation\ndescription: final validation workflow for release-readiness, residual risk classification, and single-verdict closure after the main program work is done.\ncontext: fork\nagent: qa-validation-commander\nallowed-tools: Read Grep Glob Bash\n---\n\n# Final Validation\n\n## Goal\nPrevent weak done-claims and require a real validation and verdict stage.\n\n## Outputs\n- reports/current/validation-plan.md\n- reports/current/manager-verdict.md\n\n## Rules\n- No done-claim without a validation plan.\n- Record residual risks explicitly.\n- Use the verdict scale from the master prompt.\n"
}""")
DOCS = json.loads(r"""{
  "docs/runtime/router.md": "# Runtime Router\n\n## Purpose\nDecide how the system should engage before deep work begins.\n\n## Decisions\n1. Project state: greenfield | brownfield | hybrid\n2. Intervention mode: CREATE | REPAIR | EXTEND | REFACTOR | MIGRATE | RESCUE | REPACKAGE\n3. Program depth: compact | expanded | full-office\n4. Surfaces: customer | admin | public API | backend | db | infra | mobile | web | marketing | payments | localization | compliance\n\n## Full-intent rule\nIf the user intent is clearly full, complete, or end-to-end, do not restart with menu loops. Start artefacts.\n",
  "docs/runtime/program-phases.md": "# Program Phases\n\n1. Intake and inventory\n2. Evidence and research\n3. Specialist analysis\n4. Target-state design\n5. Execution planning\n6. Pack-gap escalation\n7. Validation and manager verdict\n\nThe director may loop within phases, but the user should see forward movement, not repeated restarts.\n",
  "docs/runtime/artefact-contract.md": "# Artefact Contract\n\n## Minimum artefacts\n- runtime-manifest.md\n- assumptions.md\n- intake.md\n- inventory.md\n- evidence-register.md\n- research-notes.md\n- analysis-findings.md\n- target-state.md\n- execution-roadmap.md\n- validation-plan.md\n- pack-gap-register.md\n- manager-verdict.md\n\n## Rule\nWhen intent is clear, create artefacts immediately. Do not wait for a second round of scope confirmation unless there is a real blocker.\n",
  "docs/governance/autonomy-pressure-layer.md": "# Autonomy Pressure Layer\n\n## Goal\nPush the system to move forward when the user clearly asked for a complete program.\n\n## Rules\n- Kill repeated menu loops.\n- Prefer forward-only progress.\n- Only stop for irreversible or high-risk blockers.\n- Convert ambiguity into bounded assumptions and record them.\n",
  "docs/governance/rule-collision-matrix.md": "# Rule Collision Matrix\n\nPriority order:\n1. Security, legal, privacy\n2. Evidence quality\n3. Reversibility and rollback\n4. Validation completeness\n5. Reusable pack quality\n6. UX clarity\n7. Aesthetics\n\nIf two goals conflict, choose the higher rule and record the trade-off.\n",
  "docs/governance/plugin-skill-decision.md": "# Plugin / Skill / Agent / Command Decision\n\nUse:\n- command → repeated invocation\n- agent → specialist reasoning\n- skill → repeated workflow\n- hook → deterministic enforcement\n- MCP → external system/data/tool bridge\n- plugin → reusable distribution across projects\n\nDo not bloat the main prompt when a smaller reusable unit is better.\n",
  "docs/governance/hidden-maintainer-surface-template.md": "# Hidden Maintainer Surface Template\n\nUse this only for internal maintenance.\n\n## Keep here\n- changelog notes\n- failed experiments\n- regression notes\n- routing heuristics\n- deprecation notes\n- compatibility concerns\n",
  "docs/runtime/README.md": "# Runtime Docs\n\nThis directory holds the runtime rules, phases, router, and office roster.\n",
  "docs/governance/README.md": "# Governance Docs\n\nThis directory holds pack governance, autonomy pressure, collision rules, and maintainer-only templates.\n",
  "docs/adr/README.md": "# ADRs\n\nRecord major technical and process decisions here.\n",
  "docs/architecture/README.md": "# Architecture Docs\n\nUse this directory for target architecture, diagrams, and system notes.\n",
  "docs/release/README.md": "# Release Docs\n\nUse this directory for release plans, rollback notes, and signoff records.\n",
  "evals/assertions/README.md": "# Assertions\n\nRecommended assertions:\n- no repeated full-scope menus after explicit full intent\n- immediate artefact creation on clear intent\n- one manager verdict per full program\n- customer/admin/public API separation when relevant\n- evidence-first language\n- pack-gap register maintained\n",
  "README_RUN_ME_FIRST.md": "# RUN ME FIRST\n\n## What you have\n- `master_v10_3_autonomous_program_director_tr.md`\n- `CLAUDE.md`\n- `.claude/commands/`\n- `.claude/agents/`\n- `.claude/skills/`\n- `.claude/settings.json`\n- `.mcp.json`\n- `docs/`\n- `evals/`\n- `reports/current/`\n\n## Suggested first use in Claude Code\n1. Open this folder as your project root.\n2. Review `CLAUDE.md`.\n3. Run `/director komple` or describe your task normally.\n4. Let the Autonomous Program Director create and maintain the report artefacts.\n\n## Safe default\nThis pack is analysis-first. It should not mutate production without explicit approval.\n",
  ".gitignore": ".claude/settings.local.json\n.claude/logs/\nreports/archive/\n*.pyc\n__pycache__/\n",
  "VERSIONING.md": "# Versioning\n\nPublic releases should move in small external versions:\n- 0.1.0\n- 0.2.0\n- 0.3.0\n- ...\n- 0.9.0\n- 1.0.0\n\nKeep the large internal codename separately:\n- V8\n- V9\n- V10.2\n- V10.3\n\nExample:\nPublic: `0.6.0`\nCodename: `V10.3 Autonomous Program Director`\n"
}""")
GOLDENS = json.loads(r"""{
  "01_full_program_komple.md": "# Golden Prompt 01\n\nUser request:\n\"Komple. Projeye ortadan gir, her şeyi tara, eksikleri bul, gerekli ajanları aç, markdown artefaktları yaz ve sonunda tek verdict ver.\"\n\nExpected behavior:\n- no repeated scope menu\n- runtime-manifest, assumptions, inventory, and pack-gap-register start immediately\n- manager verdict exists\n",
  "02_greenfield_new_product.md": "# Golden Prompt 02\n\nUser request:\n\"Sıfırdan 2026 seviyesinde eğitim ürünü kur. Mimariyi, pack yapısını, araştırmayı ve ilk release planını çıkar.\"\n\nExpected behavior:\n- greenfield route\n- CREATE mode\n- target-state and roadmap first\n",
  "03_brownfield_rescue.md": "# Golden Prompt 03\n\nUser request:\n\"Bu proje dağınık, kırık ve release'e yakın. Kurtar.\"\n\nExpected behavior:\n- brownfield route\n- RESCUE mode\n- inventory, risks, rollback, validation emphasis\n",
  "04_localization_turkish.md": "# Golden Prompt 04\n\nUser request:\n\"Türkçe karakterleri, locale-aware casing'i ve eksik dilleri düzelt.\"\n\nExpected behavior:\n- localization-i18n-lead activates\n- Turkish normalization is explicit\n- language map is mentioned\n",
  "05_frontend_rebuild.md": "# Golden Prompt 05\n\nUser request:\n\"Flutter education app'i iOS-first premium 2026 seviyesine getir.\"\n\nExpected behavior:\n- frontend-ios-flutter-director, design-system-architect, educational-ux-specialist activate\n- screen-by-screen redesign output\n- implementation order is present\n"
}""")
REPORT_SPECS = json.loads(r"""{
  "runtime-manifest.md": [
    "project state",
    "intervention mode",
    "program depth",
    "active surfaces",
    "active agents",
    "blockers",
    "next phase"
  ],
  "assumptions.md": [
    "assumption",
    "why it exists",
    "risk if false",
    "how to verify"
  ],
  "intake.md": [
    "request summary",
    "known context",
    "missing context",
    "initial decomposition"
  ],
  "inventory.md": [
    "files and folders",
    "routes and screens",
    "endpoints",
    "dependencies",
    "customer/admin/public split"
  ],
  "evidence-register.md": [
    "source",
    "trust level",
    "what it supports",
    "notes"
  ],
  "research-notes.md": [
    "market signals",
    "competitors",
    "architecture currency",
    "language opportunities",
    "open questions"
  ],
  "analysis-findings.md": [
    "critical findings",
    "high findings",
    "medium findings",
    "low findings",
    "evidence-backed notes"
  ],
  "target-state.md": [
    "target architecture",
    "target UX/system",
    "target security posture",
    "target release model"
  ],
  "execution-roadmap.md": [
    "phase plan",
    "quick wins",
    "foundational work",
    "strategic work",
    "dependencies",
    "rollback notes"
  ],
  "validation-plan.md": [
    "test matrix",
    "release gates",
    "manual checks",
    "residual risks"
  ],
  "pack-gap-register.md": [
    "missing reusable units",
    "why they matter",
    "owner",
    "priority",
    "recommended path"
  ],
  "manager-verdict.md": [
    "verdict",
    "why",
    "blocking issues",
    "guardrails",
    "next move"
  ]
}""")
SETTINGS = {
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(find *)",
      "Bash(ls *)",
      "Bash(cat *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  },
  "hooks": {
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "mkdir -p .claude/logs && echo '[pre-bash]' >> .claude/logs/tool.log"}]}],
    "PostToolUse": [{"matcher": "Edit|Write", "hooks": [{"type": "command", "command": "mkdir -p .claude/logs && echo '[post-edit]' >> .claude/logs/edit.log"}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "mkdir -p .claude/logs && echo '[session-stop]' >> .claude/logs/session.log"}]}]
  },
  "disableSkillShellExecution": False
}
MCP = {
  "mcpServers": {
    "github": {"type": "http", "url": "${GITHUB_MCP_URL:-https://example.invalid/github-mcp}", "headers": {"Authorization": "Bearer ${GITHUB_TOKEN:-REPLACE_ME}"}},
    "figma": {"type": "http", "url": "${FIGMA_MCP_URL:-https://example.invalid/figma-mcp}", "headers": {"Authorization": "Bearer ${FIGMA_TOKEN:-REPLACE_ME}"}},
    "sentry": {"type": "http", "url": "${SENTRY_MCP_URL:-https://example.invalid/sentry-mcp}", "headers": {"Authorization": "Bearer ${SENTRY_TOKEN:-REPLACE_ME}"}}
  }
}

def parse_args():
    p = argparse.ArgumentParser(description="Generate the V10.3 Autonomous Program Director pack.")
    p.add_argument("--out", default=DEFAULT_OUT)
    p.add_argument("--in-place", action="store_true")
    p.add_argument("--force", action="store_true")
    p.add_argument("--zip", action="store_true")
    p.add_argument("--project-name", default="REPLACE_ME_PRODUCT")
    p.add_argument("--domain", default="REPLACE_ME_DOMAIN")
    p.add_argument("--platforms", default="web | mobile | admin | api")
    p.add_argument("--business-model", default="REPLACE_ME_BUSINESS_MODEL")
    return p.parse_args()

def safe_write(path: Path, content: str, force: bool, created: list[str], skipped: list[str]):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        old = path.read_text(encoding="utf-8")
        if old == content:
            skipped.append(f"unchanged: {path}")
            return
        if not force:
            alt = path.with_suffix(path.suffix + ".v10_3.new")
            alt.write_text(content, encoding="utf-8")
            skipped.append(f"conflict->wrote-new: {alt}")
            return
    path.write_text(content, encoding="utf-8")
    created.append(str(path))

def render_master():
    office = "\n".join(f"- {a[0]}" for a in AGENTS)
    return dedent(f"""    # MASTER V{VERSION} — AUTONOMOUS PROGRAM DIRECTOR

    **Sürüm:** {VERSION}
    **Konumlandırma:** Tek promptla veya tek proje isteğiyle çalışan; gerektiğinde kendi uzman ofisini açan; gerektiğinde pack'i büyüten; gerektiğinde komut, skill, ajan, hook ve MCP öneren ya da üreten; forward-only çalışan program direktörü.

    ## Çekirdek vaat
    Kullanıcı tek güçlü istek verdiğinde sistem:
    1. isteği route eder,
    2. greenfield / brownfield / hybrid durumunu seçer,
    3. CREATE / REPAIR / EXTEND / REFACTOR / MIGRATE / RESCUE / REPACKAGE modlarından birini seçer,
    4. gerekli uzmanları aktive eder,
    5. ilk raporları hemen açar,
    6. pack gap'lerini yazıya döker,
    7. validation koşmadan “tamam” demez.

    ## Managed full-program mode
    Aşağıdaki intent sinyallerinden biri varsa sistem tam programa geçer:
    - komple
    - hepsi
    - full
    - complete
    - baştan sona
    - uçtan uca
    - kur
    - düzelt

    Bu modda sistem tekrar tekrar kapsam menüsü açmaz.

    ## Varsayılan ofis
    {office}

    ## Zorunlu artefakt zinciri
    - reports/current/runtime-manifest.md
    - reports/current/assumptions.md
    - reports/current/intake.md
    - reports/current/inventory.md
    - reports/current/evidence-register.md
    - reports/current/research-notes.md
    - reports/current/analysis-findings.md
    - reports/current/target-state.md
    - reports/current/execution-roadmap.md
    - reports/current/validation-plan.md
    - reports/current/pack-gap-register.md
    - reports/current/manager-verdict.md

    ## Pack-gap escalation
    Aşağıdakileri açıkça yaz:
    - command eksikliği
    - agent eksikliği
    - skill pack eksikliği
    - hook eksikliği
    - MCP eksikliği
    - doc/ADR eksikliği
    - eval eksikliği
    - validation gate eksikliği

    ## Sert davranış kuralları
    - Full intent varsa menü döngüsüne girme.
    - Artefaktları başlatmadan genel konuşmada kalma.
    - Customer / admin / public API yüzeylerini karıştırma.
    - Validation koşmadan “bitti” deme.
    - Zayıf kanıtı güçlü kanıt gibi sunma.
    """)

def render_claude(args):
    return dedent(f"""    # CLAUDE.md

    @master_v10_3_autonomous_program_director_tr.md
    @docs/runtime/router.md
    @docs/runtime/program-phases.md
    @docs/runtime/artefact-contract.md
    @docs/governance/autonomy-pressure-layer.md
    @docs/governance/rule-collision-matrix.md
    @docs/governance/plugin-skill-decision.md

    ## Project Identity
    - Product: {args.project_name}
    - Domain: {args.domain}
    - Platforms: {args.platforms}
    - Primary business model: {args.business_model}
    - Current state: greenfield | brownfield | hybrid

    ## Runtime defaults
    - Prefer forward-only execution.
    - If the user intent is clearly full or complete, auto-start the first artefacts.
    - Keep customer, admin, and public API surfaces separate.
    - Use the smallest reusable unit that solves repetition.

    ## Non-negotiables
    - No destructive production mutation without explicit approval.
    - No repeated A/B/C/D menus after a full-intent request.
    - No done-claim without validation and residual risks.
    """)

def render_agent(agent):
    name, description, tools, focus, outputs = agent
    return "\n".join([
        "---",
        f"name: {name}",
        f"description: {description}",
        f"tools: {tools}",
        "---",
        "",
        f"You are the **{name}** subagent.",
        "",
        "Focus on:",
        *[f"- {x}" for x in focus],
        "",
        "Return:",
        *[f"- {x}" for x in outputs],
        "",
        "Rules:",
        "- Stay inside your specialist surface.",
        "- Use evidence-first language.",
        "- If evidence is weak, say so clearly.",
        "- Do not claim final completion; the autonomous-program-director owns the final verdict.",
        "",
    ])

def render_office_roster():
    lines = ["# Office Roster", "", "## Director", "- autonomous-program-director", "", "## Specialists"]
    for i, agent in enumerate(AGENTS[1:], start=1):
        lines.append(f"{i}. **{agent[0]}** — {agent[1]}")
    return "\n".join(lines) + "\n"

def render_report_template(filename, sections):
    title = filename.replace("-", " ").replace(".md", "").title()
    return "# " + title + "\n\n" + "\n".join([f"## {s}\n- \n" for s in sections])

def ensure_structure(root):
    for rel in [
        ".claude/commands", ".claude/agents", ".claude/skills", ".claude/logs",
        "docs/runtime", "docs/governance", "docs/adr", "docs/architecture", "docs/release",
        "evals/golden", "evals/assertions", "reports/current", "reports/archive"
    ]:
        (root / rel).mkdir(parents=True, exist_ok=True)

def write_pack(root, args):
    created, skipped = [], []
    ensure_structure(root)
    safe_write(root / "master_v10_3_autonomous_program_director_tr.md", render_master(), args.force, created, skipped)
    safe_write(root / "CLAUDE.md", render_claude(args), args.force, created, skipped)
    safe_write(root / ".claude/settings.json", json.dumps(SETTINGS, ensure_ascii=False, indent=2) + "\n", args.force, created, skipped)
    safe_write(root / ".mcp.json", json.dumps(MCP, ensure_ascii=False, indent=2) + "\n", args.force, created, skipped)
    for rel, content in DOCS.items():
        if rel.endswith("office-roster.md"):
            content = render_office_roster()
        safe_write(root / rel, content, args.force, created, skipped)
    safe_write(root / "docs/runtime/office-roster.md", render_office_roster(), args.force, created, skipped)
    for fname, content in COMMANDS.items():
        safe_write(root / ".claude/commands" / fname, content, args.force, created, skipped)
    for name, _, _, _, _ in AGENTS:
        agent = next(a for a in AGENTS if a[0] == name)
        safe_write(root / ".claude/agents" / f"{name}.md", render_agent(agent), args.force, created, skipped)
    for skill_name, skill_md in SKILLS.items():
        safe_write(root / ".claude/skills" / skill_name / "SKILL.md", skill_md, args.force, created, skipped)
    for fname, content in GOLDENS.items():
        safe_write(root / "evals/golden" / fname, content, args.force, created, skipped)
    for fname, sections in REPORT_SPECS.items():
        safe_write(root / "reports/current" / fname, render_report_template(fname, sections), args.force, created, skipped)
    safe_write(root / "docs/adr/ADR-000-pack-foundation.md", dedent("""    # ADR-000 — Adopt V10.3 Autonomous Program Director Pack

    ## Status
    Accepted

    ## Context
    The project needs a forward-only, artefact-driven operating system that can work from greenfield, mid-project, or rescue conditions.

    ## Decision
    Adopt the V10.3 Autonomous Program Director pack with:
    - CLAUDE.md imports
    - project skills and commands
    - project subagents
    - project-scoped settings and MCP config
    - report artefacts and eval prompts

    ## Consequences
    - better repeatability
    - stronger routing
    - explicit pack-gap management
    - higher maintainer overhead than a single prompt, but much better control
    """), args.force, created, skipped)
    safe_write(root / "reports/README.md", "# Reports\n\n`reports/current/` is the active working set. Move finished runs into `reports/archive/`.\n", args.force, created, skipped)
    return created, skipped

def create_zip(root):
    target = root.with_suffix(".zip")
    if target.exists():
        target.unlink()
    shutil.make_archive(str(root), "zip", root)
    return target

def main():
    args = parse_args()
    out = Path.cwd() if args.in_place else Path(args.out).resolve()
    if not args.in_place:
        out.mkdir(parents=True, exist_ok=True)
    created, skipped = write_pack(out, args)
    try:
        me = Path(__file__).resolve()
        target = out / "_bootstrap" / me.name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(me.read_text(encoding="utf-8"), encoding="utf-8")
    except Exception:
        pass
    z = create_zip(out) if args.zip else None
    print("\nV10.3 pack generation complete.")
    print(f"Output: {out}")
    print(f"Files written/updated: {len(created)}")
    print(f"Files skipped/conflicted: {len(skipped)}")
    if z:
        print(f"Zip: {z}")
    print("\nSuggested next steps:")
    print("1. Open the output folder in Claude Code.")
    print("2. Review CLAUDE.md and the docs/runtime directory.")
    print("3. Run /director komple or describe your task normally.")
    print("4. Let the director maintain reports/current/ as the source of truth.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
