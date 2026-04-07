# Ulak OS - awesome-design-md fetch helper (Windows PowerShell)
# Run with: powershell -ExecutionPolicy Bypass -File scripts\fetch-design-references.ps1 stripe
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Brand
)

$ErrorActionPreference = 'Stop'

$UpstreamBase = "https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main"
$TargetDir = "reports/current/design-references"
$BrandLower = $Brand.ToLower()

New-Item -ItemType Directory -Force -Path "$TargetDir/$BrandLower" | Out-Null

Write-Host "Fetching DESIGN.md for $Brand from awesome-design-md..."

$Urls = @(
    "$UpstreamBase/$BrandLower/DESIGN.md",
    "$UpstreamBase/sites/$BrandLower/DESIGN.md",
    "$UpstreamBase/brands/$BrandLower/DESIGN.md"
)

$Found = $false
foreach ($url in $Urls) {
    try {
        Invoke-WebRequest -Uri $url -OutFile "$TargetDir/$BrandLower/DESIGN.md" -ErrorAction Stop | Out-Null
        Write-Host "[OK] Downloaded from: $url"
        $Found = $true
        break
    } catch {
        continue
    }
}

if (-not $Found) {
    Write-Host "[X] Could not find DESIGN.md for '$Brand' at any expected upstream path."
    Write-Host "    Browse manually: https://github.com/VoltAgent/awesome-design-md"
    Remove-Item -Path "$TargetDir/$BrandLower" -ErrorAction SilentlyContinue
    exit 1
}

# Best-effort preview files
foreach ($preview in @("preview.html", "preview-dark.html")) {
    foreach ($base in @("$UpstreamBase/$BrandLower", "$UpstreamBase/sites/$BrandLower", "$UpstreamBase/brands/$BrandLower")) {
        try {
            Invoke-WebRequest -Uri "$base/$preview" -OutFile "$TargetDir/$BrandLower/$preview" -ErrorAction Stop | Out-Null
            Write-Host "[OK] Bonus: $preview"
            break
        } catch {
            continue
        }
    }
}

Write-Host ""
Write-Host "[OK] Design reference for '$Brand' written to: $TargetDir/$BrandLower/"
exit 0
