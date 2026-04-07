# Ulak OS - Claude Code init (Windows PowerShell)
# Run with: powershell -ExecutionPolicy Bypass -File scripts\init-claude.ps1

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== Ulak OS -> Claude Code init ==="
Write-Host ""

$WarnCount = 0

# 1. Binary check
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    Write-Host "[X] 'claude' binary not found in PATH."
    Write-Host "    Install Claude Code: https://claude.com/claude-code"
    exit 1
}
Write-Host "[OK] claude binary found: $($claudeCmd.Source)"

# 2. Required files check
$RequiredFiles = @(
    "CLAUDE.md",
    "prompts/core/ulak-os-core-contract-1.0.0.md",
    ".claude/settings.json"
)
foreach ($f in $RequiredFiles) {
    if (-not (Test-Path $f)) {
        Write-Host "[X] Required file missing: $f"
        Write-Host "    Are you running this from the ulak-os repo root?"
        exit 1
    }
}
Write-Host "[OK] All required files present"

# 3. MCP env var check (warn only)
$McpVars = @("GITHUB_MCP_URL", "GITHUB_TOKEN", "JIRA_MCP_URL", "JIRA_TOKEN", "FIGMA_MCP_URL", "FIGMA_TOKEN")
$MissingMcp = @()
foreach ($v in $McpVars) {
    if (-not [Environment]::GetEnvironmentVariable($v)) {
        $MissingMcp += $v
    }
}
if ($MissingMcp.Count -gt 0) {
    Write-Host "[!] MCP env vars not set: $($MissingMcp -join ', ')"
    Write-Host "    MCP connectors will be disabled. See README.md for setup."
    $WarnCount++
}

# 4. Reports directory
New-Item -ItemType Directory -Force -Path "reports/current" | Out-Null
Write-Host "[OK] reports/current/ ready"

# 5. Next command
Write-Host ""
Write-Host "=== Setup complete ==="
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Start Claude Code:    claude"
Write-Host "  2. Verify memory loaded:  /memory"
Write-Host "  3. Run first command:    /director komple"
Write-Host ""

if ($WarnCount -gt 0) {
    Write-Host "(Completed with $WarnCount warning(s) - see above.)"
    exit 2
}
exit 0
