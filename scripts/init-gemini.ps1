# Ulak OS - Gemini CLI init (Windows PowerShell)
$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== Ulak OS -> Gemini CLI init ==="
Write-Host ""

$WarnCount = 0

# 1. Binary check
$geminiCmd = Get-Command gemini -ErrorAction SilentlyContinue
if (-not $geminiCmd) {
    Write-Host "[X] 'gemini' binary not found in PATH."
    Write-Host "    Install Gemini CLI: https://github.com/google-gemini/gemini-cli"
    exit 1
}
Write-Host "[OK] gemini binary found: $($geminiCmd.Source)"

# 2. Required files check
$RequiredFiles = @(
    "GEMINI.md",
    "prompts/core/ulak-os-core-contract-1.0.0.md",
    "docs/adapters/gemini-cli.md"
)
foreach ($f in $RequiredFiles) {
    if (-not (Test-Path $f)) {
        Write-Host "[X] Required file missing: $f"
        exit 1
    }
}
Write-Host "[OK] All required files present"

# 3. Gemini commands check
if (-not (Test-Path ".gemini/commands")) {
    Write-Host "[X] .gemini/commands/ directory missing"
    exit 1
}
$TomlCount = (Get-ChildItem -Path ".gemini/commands" -Filter "*.toml" -Recurse).Count
if ($TomlCount -lt 1) {
    Write-Host "[!] No .toml command files found"
    $WarnCount++
}
Write-Host "[OK] Found $TomlCount TOML command(s)"

# 4. Reports directory
New-Item -ItemType Directory -Force -Path "reports/current" | Out-Null
Write-Host "[OK] reports/current/ ready"

# 5. Next command
Write-Host ""
Write-Host "=== Setup complete ==="
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Start Gemini CLI:      gemini"
Write-Host "  2. Reload memory:         /memory reload"
Write-Host "  3. Reload commands:       /commands reload"
Write-Host "  4. Run first command:    /director komple"
Write-Host ""

if ($WarnCount -gt 0) {
    exit 2
}
exit 0
