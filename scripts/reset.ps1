$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "This drops the local Docker volume and recreates the database."
docker compose down -v
docker compose up -d

Write-Host "Waiting for Postgres to finish first-boot init..."
$ready = $false
for ($i = 0; $i -lt 40; $i++) {
    docker exec legalhelpdb pg_isready -U legalhelp -d legalhelpdb 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $ready = $true
        break
    }
    Start-Sleep -Seconds 2
}

if (-not $ready) {
    throw "Postgres did not become ready in time. Check: docker compose logs postgres"
}

Write-Host "Database reset complete."
