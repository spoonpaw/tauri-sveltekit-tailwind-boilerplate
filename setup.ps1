#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "[setup] Installing frontend dependencies (npm ci) ..." -ForegroundColor Cyan
Set-Location "$RootDir\frontend"

if (Test-Path "package-lock.json") {
    # npm ci requires package-lock.json to match package.json exactly.
    # When deps change, fall back to npm install to refresh the lockfile.
    try {
        npm ci
        if ($LASTEXITCODE -ne 0) { throw "npm ci failed" }
    }
    catch {
        Write-Host "[setup] npm ci failed (lockfile likely out of sync). Falling back to npm install ..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) { exit 1 }
    }
}
else {
    npm install
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

Write-Host ""
Write-Host "[setup] Done." -ForegroundColor Green
Write-Host "[setup] Next:"
Write-Host "  - Dev:   .\dev.ps1"
Write-Host "  - Build: .\build.ps1"
