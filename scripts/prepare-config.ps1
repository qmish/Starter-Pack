# Подготавливает collector/config.yaml из выбранного шаблона и .env
# Использование: .\scripts\prepare-config.ps1 [-Preset full|docker|vm]
# По умолчанию: full

param(
    [ValidateSet('full','docker','vm')]
    [string] $Preset = 'full'
)

$ErrorActionPreference = 'Stop'
$RootDir = Split-Path $PSScriptRoot -Parent
$CollectorDir = Join-Path $RootDir "collector"
$Source = Join-Path $CollectorDir "config.$Preset.yaml"
$Target = Join-Path $CollectorDir "config.yaml"

if (-not (Test-Path $Source)) {
    Write-Error "Config template not found: $Source"
    exit 1
}

$Endpoint = "<SIGNOZ_ENDPOINT>"
$Key = "<INGESTION_KEY>"

$EnvPath = Join-Path $RootDir ".env"
if (Test-Path $EnvPath) {
    Get-Content $EnvPath | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $name = $Matches[1].Trim()
            $value = $Matches[2].Trim().Trim('"').Trim("'")
            Set-Item -Path "Env:$name" -Value $value
        }
    }
    if ($Env:SIGNOZ_OTEL_ENDPOINT) { $Endpoint = $Env:SIGNOZ_OTEL_ENDPOINT }
    if ($Env:SIGNOZ_INGESTION_KEY) { $Key = $Env:SIGNOZ_INGESTION_KEY }
}

$content = Get-Content $Source -Raw
$content = $content -replace '<SIGNOZ_ENDPOINT>', $Endpoint -replace '<INGESTION_KEY>', $Key
Set-Content -Path $Target -Value $content -NoNewline

Write-Host "Written $Target from config.$Preset.yaml"
Write-Host "Endpoint: $Endpoint"
