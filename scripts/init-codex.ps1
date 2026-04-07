# Ulak OS - Codex/Copilot init (Windows PowerShell)
$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== Ulak OS -> Codex/Copilot init ==="
Write-Host ""

# 1. Binary check (try codex, copilot, gh)
$FoundBinary = $null
foreach ($bin in @("codex", "copilot", "gh")) {
    if (Get-Command $bin -ErrorAction SilentlyContinue) {
        $FoundBinary = $bin
        break
    }
}
if (-not $FoundBinary) {
    Write-Host "[X] No compatible binary found (tried: codex, copilot, gh)."
    Write-Host "    Install one of:"
    Write-Host "    - GitHub Copilot CLI: https://github.com/github/gh-copilot"
    Write-Host "    - OpenAI Codex CLI:    https://github.com/openai/codex"
    exit 1
}
Write-Host "[OK] Found agent binary: $FoundBinary"

# 2. Required files check
$RequiredFiles = @(
    "AGENTS.md",
    "CLAUDE.md",
    ".github/copilot-instructions.md",
    "docs/adapters/codex-cli.md",
    "docs/adapters/universal-runtime-contract.md"
)
foreach ($f in $RequiredFiles) {
    if (-not (Test-Path $f)) {
        Write-Host "[X] Required file missing: $f"
        exit 1
    }
}
Write-Host "[OK] All required files present"

# 3. Reports directory
New-Item -ItemType Directory -Force -Path "reports/current" | Out-Null
Write-Host "[OK] reports/current/ ready"

# 4. Next command
Write-Host ""
Write-Host "=== Setup complete ==="
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Start your agent ($FoundBinary)"
Write-Host "  2. Tell the agent:"
Write-Host "     'Read AGENTS.md, CLAUDE.md, docs/adapters/codex-cli.md and"
Write-Host "      docs/adapters/universal-runtime-contract.md, then run the"
Write-Host "      appropriate program mode.'"
Write-Host ""
exit 0
