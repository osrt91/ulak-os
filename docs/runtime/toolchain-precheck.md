# Toolchain Precheck

## Why this exists

Before any serious plan, the director needs to know what's actually installed, what's missing, and what the project *requires* vs. what's merely convenient. Without a toolchain precheck, the director proposes "run `pnpm build`" on a machine with no Node, or recommends Flutter patterns for a React Native project. Toolchain precheck is the ground truth that Phase 4 (synthesis) stands on.

## When it runs

The toolchain precheck runs in Phase 0 (environment lock) as part of `runtime-manifest.md`, and again in Phase 7 (validate) before validation gates execute. If the precheck in Phase 0 reveals a missing tool that a later phase needs, the director must surface this in `pack-gap-register.md` and either halt or proceed in degraded mode with explicit logging.

## Fields per tool

For every detected or required tool, emit this shape:

```yaml
tool: ""                                  # e.g. "pnpm", "flutter", "docker"
status: required|conditional|optional|not-needed|not-recommended
reason: ""                                # why the status applies to this project
detected_version: ""                      # or "missing"
baseline_version: ""                      # minimum the project needs
install_hint: ""                          # preferred install command
verify_command: ""                        # command to confirm presence and version
risk_note: ""                             # e.g. "conflicts with existing Node 16 on this machine"
trust: T1|T2|T3|T4|T5|T6|T7               # how the detection was done
```

## Status definitions

- **required** — the project cannot build/test/run without this tool. No ambiguity.
- **conditional** — needed only if a specific surface is in scope (e.g. Xcode is required *if* iOS is in scope)
- **optional** — improves DX but not strictly needed
- **not-needed** — explicitly irrelevant to this project (don't list every tool in the world)
- **not-recommended** — present but the project should not depend on it (e.g. yarn v1 on a pnpm project)

## Standard tools to detect

Not exhaustive. The cartographer + the precheck together should decide which to actually query based on the project.

### Core environment
- OS (win32, darwin, linux)
- shell (bash, zsh, pwsh, fish)
- git

### JavaScript / TypeScript
- node (version baseline)
- pnpm / npm / yarn / bun
- Claude Code (installed via npm; requires Node 18+)

### Python
- python (3.x line)
- uv / pipx / pip
- virtualenv or venv

### Native mobile
- Xcode + xcode-select
- CocoaPods
- fastlane
- Android Studio / Android SDK / adb
- Java / Gradle / Kotlin

### Flutter / Dart
- flutter
- dart

### Containers / infra
- docker / docker compose
- kubectl / helm (only if k8s in scope)
- terraform (only if IaC in scope)

### Tooling
- jq / yq
- make / just / task
- direnv / dotenv

### Test / lint / format
- language-specific linters (eslint, ruff, clippy, ktlint, swiftlint)
- language-specific formatters (prettier, black, gofmt)
- test runners (vitest, jest, pytest, go test, xctest)

### Observability
- sentry CLI
- datadog agent hooks
- opentelemetry collector (only if relevant)

### Distribution / signing
- fastlane (iOS / Android)
- store Connect CLI
- gh (GitHub CLI)

### Claude runtime
- `CLAUDE.md` presence
- `.claude/settings.json` presence
- `.claude/commands/` presence
- `.claude/agents/` presence
- `.mcp.json` presence

## Hard rules

- **Do not say "install everything".** Separate required, conditional, optional, not-needed.
- **Do not recommend tools that conflict with the existing stack.** A React project does not need Flutter tooling.
- **Native mobile tooling is not optional when mobile is in scope.** iOS work without Xcode / CocoaPods is fiction.
- **"Claude only" does not mean "no project dependencies".** Claude Code itself needs Node 18+ to install.
- **Record detection evidence with a trust tier.** A T2 detection from the repo (package.json says pnpm) beats a T7 guess.

## Integration

- Phase 0 emits the precheck as part of `runtime-manifest.md`
- Phase 7 re-runs key checks before validation gates
- `docs/runtime/validation-result-schema.md` gate evidence must reference the precheck output for the relevant tool
- `pack-gap-register.md` lists any missing tools as gap entries
