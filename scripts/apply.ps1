param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$sqlRoot = Join-Path $root "db"
$container = "legalhelpdb"

$envFile = Join-Path $root ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
        $name, $value = $_.Split('=', 2)
        Set-Item -Path "Env:$($name.Trim())" -Value $value.Trim()
    }
}

function Find-Psql {
    $cmd = Get-Command psql -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $roots = @()
    if ($env:ProgramFiles) {
        $roots += Join-Path $env:ProgramFiles "PostgreSQL"
    }
    $programFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
    if ($programFilesX86) {
        $roots += Join-Path $programFilesX86 "PostgreSQL"
    }
    $roots = $roots | Where-Object { Test-Path $_ }

    foreach ($pgRoot in $roots) {
        $candidate = Get-ChildItem $pgRoot -Directory -ErrorAction SilentlyContinue |
            Sort-Object { [int](($_.Name -split '\.')[0]) } -Descending |
            ForEach-Object { Join-Path $_.FullName "bin\psql.exe" } |
            Where-Object { Test-Path $_ } |
            Select-Object -First 1
        if ($candidate) { return $candidate }
    }

    return $null
}

function Test-DockerContainerRunning {
    param([string]$Name)

    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) { return $false }

    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $running = & docker ps --filter "name=$Name" --format "{{.Names}}" 2>$null
        return ($LASTEXITCODE -eq 0 -and $running -eq $Name)
    } catch {
        return $false
    } finally {
        $ErrorActionPreference = $oldEap
    }
}

function Invoke-PsqlFile {
    param(
        [string]$PsqlPath,
        [string]$HostName,
        [string]$Port,
        [string]$UserName,
        [string]$Database,
        [string]$FilePath
    )

    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & $PsqlPath -v ON_ERROR_STOP=1 -h $HostName -p $Port -U $UserName -d $Database -f $FilePath
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldEap
    }

    if ($code -ne 0) {
        throw "Failed applying $(Split-Path $FilePath -Leaf)"
    }
}

function Invoke-PsqlQuery {
    param(
        [string]$PsqlPath,
        [string]$HostName,
        [string]$Port,
        [string]$UserName,
        [string]$Database,
        [string]$Query
    )

    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $PsqlPath -tAc $Query -h $HostName -p $Port -U $UserName -d $Database 2>&1
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldEap
    }

    $text = ($output | ForEach-Object { "$_" }) -join "`n"
    return @{
        ExitCode = $code
        Output   = $text
    }
}

$files = Get-ChildItem -Path $sqlRoot -Recurse -Filter *.sql |
    Where-Object {
        $_.FullName -notmatch '[\\/]09_seeds[\\/]demo[\\/]' -and
        $_.FullName -notmatch '[\\/]10_rollback[\\/]'
    } |
    Sort-Object FullName

if (-not $files) {
    throw "No SQL files found under $sqlRoot"
}

$db = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "legalhelpdb" }

if (Test-DockerContainerRunning -Name $container) {
    $user = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "legalhelp" }
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($sqlRoot.Length).TrimStart('\', '/').Replace('\', '/')
        Write-Host "Applying /sql/$relative"
        docker exec -i $container psql -v ON_ERROR_STOP=1 -U $user -d $db -f "/sql/$relative"
        if ($LASTEXITCODE -ne 0) { throw "Failed applying $relative" }
    }
    Write-Host "Schema apply complete."
    exit 0
}

$psqlPath = Find-Psql
if (-not $psqlPath) {
    throw "Local psql was not found. Install PostgreSQL or start Docker Desktop and retry."
}

$hostName = if ($env:POSTGRES_HOST) { $env:POSTGRES_HOST } else { "localhost" }
$port = if ($env:POSTGRES_PORT) { $env:POSTGRES_PORT } else { "5432" }
$envUser = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { $null }

$candidateUsers = @()
if ($envUser) { $candidateUsers += $envUser }
foreach ($fallback in @("postgres", $env:USERNAME)) {
    if ($fallback -and $candidateUsers -notcontains $fallback) {
        $candidateUsers += $fallback
    }
}

$user = $null
foreach ($candidate in $candidateUsers) {
    if ($candidate -eq $envUser -and $env:POSTGRES_PASSWORD) {
        $env:PGPASSWORD = $env:POSTGRES_PASSWORD
    } else {
        Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
    }

    $probe = Invoke-PsqlQuery -PsqlPath $psqlPath -HostName $hostName -Port $port -UserName $candidate -Database "postgres" -Query "SELECT 1"
    if ($probe.ExitCode -eq 0) {
        $user = $candidate
        break
    }
}

if (-not $user) {
    throw "Could not connect to PostgreSQL at ${hostName}:${port}. Tried users: $($candidateUsers -join ', ')."
}

Write-Host "Using $psqlPath as $user@$hostName`:$port"

$exists = Invoke-PsqlQuery -PsqlPath $psqlPath -HostName $hostName -Port $port -UserName $user -Database "postgres" -Query "SELECT 1 FROM pg_database WHERE datname = '$db'"
if ($exists.Output.Trim() -ne "1") {
    Write-Host "Creating database $db"
    $created = Invoke-PsqlQuery -PsqlPath $psqlPath -HostName $hostName -Port $port -UserName $user -Database "postgres" -Query "CREATE DATABASE `"$db`""
    if ($created.ExitCode -ne 0) {
        throw "Failed creating database $db : $($created.Output)"
    }
}

$installed = Invoke-PsqlQuery -PsqlPath $psqlPath -HostName $hostName -Port $port -UserName $user -Database $db -Query "SELECT 1 FROM information_schema.schemata WHERE schema_name = 'identity'"
$alreadyInstalled = ($installed.Output.Trim() -eq "1")

if ($alreadyInstalled -and -not $Force) {
    Write-Host "Schema already installed on $db. Re-run with -Force to rebuild."
    exit 0
}

if ($alreadyInstalled -and $Force) {
    Write-Host "Dropping existing LegalHelp schemas on $db"
    $dropSql = @"
DROP SCHEMA IF EXISTS identity, catalog, authorities, cases, documents, consultations, drafts, billing, comms, followups, research, content, audit CASCADE;
DROP FUNCTION IF EXISTS public.set_updated_at() CASCADE;
"@
    $dropped = Invoke-PsqlQuery -PsqlPath $psqlPath -HostName $hostName -Port $port -UserName $user -Database $db -Query $dropSql
    if ($dropped.ExitCode -ne 0) {
        throw "Failed dropping existing schemas: $($dropped.Output)"
    }
}

foreach ($file in $files) {
    $relative = $file.FullName.Substring($sqlRoot.Length).TrimStart('\', '/').Replace('\', '/')
    Write-Host "Applying $relative"
    Invoke-PsqlFile -PsqlPath $psqlPath -HostName $hostName -Port $port -UserName $user -Database $db -FilePath $file.FullName
}

Write-Host "Schema apply complete."
