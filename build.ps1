#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "[build] Building frontend (SvelteKit/Vite) -> frontend/build ..." -ForegroundColor Cyan
Set-Location "$RootDir\frontend"
npm run build
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "[build] Building Tauri bundles ..." -ForegroundColor Cyan
Set-Location "$RootDir\backend"

# Check for Tauri CLI
$tauriCmd = Get-Command tauri -ErrorAction SilentlyContinue
$cargoTauri = $null
if (-not $tauriCmd) {
    try {
        $null = cargo tauri --version 2>$null
        $cargoTauri = $true
    }
    catch {
        $cargoTauri = $false
    }
}

if ($tauriCmd) {
    tauri build @args
}
elseif ($cargoTauri) {
    cargo tauri build @args
}
else {
    Write-Host "[build] ERROR: No Tauri CLI found." -ForegroundColor Red
    Write-Host "[build] Install one of:" -ForegroundColor Red
    Write-Host "  - npm:   npm install -g `"@tauri-apps/cli@^2`"" -ForegroundColor Yellow
    Write-Host "  - cargo: cargo install tauri-cli" -ForegroundColor Yellow
    exit 1
}
