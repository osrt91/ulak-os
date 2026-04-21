# Architecture Docs

This directory contains the architectural reference for Ulak OS — how the pieces fit together, how a run flows, how vendors plug in. Diagrams use GitHub-native mermaid (`graph TD`, `flowchart TD`, `sequenceDiagram`) so they render directly in the web UI with no external tooling.

Readers in a hurry: start with [`overview.md`](./overview.md). Operators scaffolding a new SaaS: start with [`scaffolder-flow.md`](./scaffolder-flow.md). Vendors porting the core contract: start with [`vendor-adapters.md`](./vendor-adapters.md).

## Index

### English

- **[overview.md](./overview.md)** — System architecture. How `CLAUDE.md` loads the core contract, how runtime rules + governance + operational motors assemble the active surface, how commands trigger agents that write artefacts. One mermaid `graph TD`.
- **[director-protocol.md](./director-protocol.md)** — The six-phase `/director komple` protocol with artefact outputs and rejection gates. One mermaid `flowchart TD` + detailed gate table + common failure modes.
- **[scaffolder-flow.md](./scaffolder-flow.md)** — The `/ulak-scaffold` sequence from operator prompt to shippable SaaS skeleton. One mermaid `sequenceDiagram` + 27-template inventory + "what you get on commit 1" guarantees.
- **[vendor-adapters.md](./vendor-adapters.md)** — Topology across Claude Code, Codex/Copilot, and Gemini CLI. One mermaid `graph TD` + vendor convention table + parity enforcement notes.

### Türkçe

- **[overview.md](./overview.md)** — Sistem mimarisi. `CLAUDE.md` core contract'ı nasıl yüklüyor, runtime/governance/operational katmanları nasıl birleşiyor, komutlar hangi ajanları tetikleyip hangi artefaktları yazıyor.
- **[director-protocol.md](./director-protocol.md)** — `/director komple` altı-faz protokolü; her faz için artefakt çıktıları ve reddetme kapıları.
- **[scaffolder-flow.md](./scaffolder-flow.md)** — `/ulak-scaffold` akışı; operatör prompt'undan ship edilebilir SaaS iskeletine.
- **[vendor-adapters.md](./vendor-adapters.md)** — Claude Code / Codex / Gemini CLI üzerinde topoloji ve parity disiplini.

## Diagram tooling

All diagrams are GitHub-native mermaid. No Lucidchart, no draw.io, no Miro. If you view this repo on GitHub or any Markdown renderer with mermaid support, the diagrams render inline. If you read raw `.md`, you see the mermaid source — which is intentional and readable.

## Cross-references

- [`prompts/core/ulak-os-core-contract-2.0.0.md`](../../prompts/core/ulak-os-core-contract-2.0.0.md) — the vendor-neutral core contract these docs describe
- [`docs/adapters/claude-code.md`](../adapters/claude-code.md) — Claude Code adapter spec (primary target)
- [`docs/adapters/codex-cli.md`](../adapters/codex-cli.md) — Codex / Copilot adapter spec
- [`docs/adapters/gemini-cli.md`](../adapters/gemini-cli.md) — Gemini CLI adapter spec
- [`docs/adr/README.md`](../adr/README.md) — ADRs explaining why the architecture is what it is

## Canonical footer

Authoritative as of Ulak OS **v2.4.1** (Phase 3.0-B).
