#Requires -Version 5.1
<#
.SYNOPSIS
    Integrate Ulak OS into sibling projects (one-shot, idempotent).
.DESCRIPTION
    For each project sibling of ulak.os, wires in:
      - CLAUDE.md import line (appended if file exists, created minimal if not)
      - ulak.config.json (skip if exists)
      - .ulak/sessions/.gitkeep
      - reports/current/.gitkeep
      - .gitignore entries for ulak runtime
    Commands/agents/skills are expected at user-global (~/.claude/).
#>
[CmdletBinding()]
param(
    [string]$ProjectsRoot = "C:\Users\osrt91\Desktop\Proje",
    [string[]]$Projects,
    [string]$UlakImport = "@../ulak.os/prompts/core/ulak-os-core-contract-2.0.0.md"
)

$ErrorActionPreference = 'Stop'

if (-not $Projects -or $Projects.Count -eq 0) {
    Write-Error "Pass -Projects <name1>,<name2>,..."
    exit 2
}

$gitignoreBlock = @"

# Ulak OS runtime
.ulak/
reports/current/*
!reports/current/.gitkeep
"@

$ulakConfig = @'
{
  "version": "2.0.0",
  "vendor": "claude",
  "promptPack": "ulak-os@2.0.0",
  "memory": {
    "backend": "sqlite",
    "path": ".ulak/memory.db"
  },
  "artefacts": {
    "outputDir": "reports/current"
  }
}
'@

foreach ($name in $Projects) {
    $root = Join-Path $ProjectsRoot $name
    if (-not (Test-Path $root)) {
        Write-Host "[SKIP] $name : not found" -ForegroundColor Yellow
        continue
    }

    Write-Host ""
    Write-Host "=== $name ===" -ForegroundColor Cyan

    # Clear read-only dir attribute if set
    $attr = (Get-Item $root -Force).Attributes
    if ($attr -band [System.IO.FileAttributes]::ReadOnly) {
        attrib -R "$root" /S /D | Out-Null
        Write-Host "  cleared ReadOnly attribute"
    }

    # 1) CLAUDE.md
    $claude = Join-Path $root 'CLAUDE.md'
    if (Test-Path $claude) {
        $body = Get-Content $claude -Raw
        if ($body -match 'ulak-os-core-contract') {
            Write-Host "  CLAUDE.md already imports ulak-os  (skip)"
        } else {
            Copy-Item $claude "$claude.ulak-backup" -Force
            Add-Content -Path $claude -Value "`n$UlakImport" -Encoding UTF8
            Write-Host "  CLAUDE.md : appended import (backup: CLAUDE.md.ulak-backup)"
        }
    } else {
        $header = "# $name`n`n$UlakImport`n"
        Set-Content -Path $claude -Value $header -Encoding UTF8
        Write-Host "  CLAUDE.md : created with import"
    }

    # 2) ulak.config.json
    $cfg = Join-Path $root 'ulak.config.json'
    if (Test-Path $cfg) {
        Write-Host "  ulak.config.json already exists  (skip)"
    } else {
        Set-Content -Path $cfg -Value $ulakConfig -Encoding UTF8
        Write-Host "  ulak.config.json : created"
    }

    # 3+4) Runtime dirs with .gitkeep
    foreach ($pair in @(
        @{ dir = '.ulak\sessions' },
        @{ dir = 'reports\current' }
    )) {
        $dir = Join-Path $root $pair.dir
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $keep = Join-Path $dir '.gitkeep'
        if (-not (Test-Path $keep)) { New-Item -ItemType File -Path $keep | Out-Null }
    }
    Write-Host "  .ulak/sessions/.gitkeep  +  reports/current/.gitkeep : ensured"

    # 5) .gitignore
    $gi = Join-Path $root '.gitignore'
    if (Test-Path $gi) {
        $giBody = Get-Content $gi -Raw
        if ($giBody -match '\.ulak/') {
            Write-Host "  .gitignore already has ulak entries  (skip)"
        } else {
            Add-Content -Path $gi -Value $gitignoreBlock -Encoding UTF8
            Write-Host "  .gitignore : appended ulak entries"
        }
    } else {
        Set-Content -Path $gi -Value $gitignoreBlock.TrimStart() -Encoding UTF8
        Write-Host "  .gitignore : created with ulak entries"
    }
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
