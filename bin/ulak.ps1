#Requires -Version 5.1
[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
$ErrorActionPreference = 'Stop'
$UlakHome = $env:ULAK_HOME
if (-not $UlakHome) { $UlakHome = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path) }

function Read-UlakVersion {
    $p = Join-Path $UlakHome 'prompts\pack.json'
    if (Test-Path $p) {
        $j = Get-Content $p -Raw | ConvertFrom-Json
        return $j.version
    }
    return 'unknown'
}

function Invoke-UlakInit {
    param([string]$Target)
    if (-not $Target) { Write-Error "ulak init: missing <project-dir>"; exit 2 }
    if (-not (Test-Path $Target -PathType Container)) { Write-Error "not a directory: $Target"; exit 1 }
    $claude = Join-Path $Target 'CLAUDE.md'
    $import = "@$UlakHome\prompts\core\ulak-os-core-contract-2.0.0.md"
    if (Test-Path $claude) {
        if (Select-String -Path $claude -Pattern 'ulak-os-core-contract' -Quiet) {
            Write-Host "[ulak] CLAUDE.md already references Ulak OS core -- no change."
            return
        }
        Copy-Item $claude "$claude.ulak-backup" -Force
        Add-Content $claude "`n# Ulak OS governance (added by ulak init)`n$import"
        Write-Host "[ulak] appended import to existing CLAUDE.md (backup: CLAUDE.md.ulak-backup)"
    } else {
        $header = "# $(Split-Path -Leaf $Target) -- project memory`n`n$import`n`n## Runtime defaults`n- validation olmadan done deme`n- artefakt zincirini erken baslat`n"
        Set-Content -Path $claude -Value $header -Encoding UTF8
        Write-Host "[ulak] created CLAUDE.md with Ulak OS core import"
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $Target 'reports\current') | Out-Null
}

$sub = if ($Args.Count -gt 0) { $Args[0] } else { 'help' }
$rest = if ($Args.Count -gt 1) { $Args[1..($Args.Count-1)] } else { @() }

switch ($sub) {
    '--version' { Write-Host "ulak $(Read-UlakVersion) (install: $UlakHome)" }
    '-v'        { Write-Host "ulak $(Read-UlakVersion) (install: $UlakHome)" }
    'version'   { Write-Host "ulak $(Read-UlakVersion) (install: $UlakHome)" }
    'init'      { Invoke-UlakInit -Target $rest[0] }
    'where'     { Write-Host $UlakHome }
    'update'    { & git -C $UlakHome pull --ff-only }
    'doctor'    {
        foreach ($s in 'scripts\validate-imports.sh','scripts\validate-schemas.sh','scripts\validate-vendor-parity.sh') {
            $full = Join-Path $UlakHome $s
            if (Test-Path $full) {
                Write-Host "[ulak] running $s"
                & bash $full
            }
        }
    }
    default {
        Write-Host "ulak -- Ulak OS CLI wrapper`nUsage: ulak [--version|init (dir)|doctor|update|where|help]"
    }
}
