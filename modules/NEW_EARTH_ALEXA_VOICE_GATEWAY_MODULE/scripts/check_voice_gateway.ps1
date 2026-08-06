param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Split-Path -Parent $scriptDir
$envFile = Join-Path $moduleRoot '.env.local'
$fallbackEnvFile = Join-Path $moduleRoot '.env'
$gatewayUrl = 'http://127.0.0.1:8088/voice/command'
$healthUrl = 'http://127.0.0.1:8088/health'
$secret = $null

function Get-DotEnvValue {
  param(
    [string]$Path,
    [string]$Name
  )

  if (-not (Test-Path $Path)) {
    return $null
  }

  foreach ($line in Get-Content -Path $Path) {
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith('#')) {
      continue
    }

    $prefix = "$Name="
    if ($trimmed.StartsWith($prefix)) {
      return $trimmed.Substring($prefix.Length).Trim()
    }
  }

  return $null
}

$secret = Get-DotEnvValue -Path $envFile -Name 'NEW_EARTH_VOICE_GATEWAY_SECRET'
if (-not $secret) {
  $secret = Get-DotEnvValue -Path $fallbackEnvFile -Name 'NEW_EARTH_VOICE_GATEWAY_SECRET'
}

$requestBody = @{
  source = 'local-check'
  intent = 'GetTodaySummaryIntent'
  command = 'dashboard.summary.today'
  slots = @{}
} | ConvertTo-Json -Compress

try {
  $health = Invoke-RestMethod -Uri $healthUrl -Method Get
  Write-Host 'Gateway health: RUNNING' -ForegroundColor Green
  Write-Host "Service: $($health.service)"
  Write-Host "Enabled: $($health.enabled)"
  Write-Host "Time: $($health.time)"
} catch {
  Write-Host 'Gateway health: STOPPED' -ForegroundColor Red
  Write-Host $_.Exception.Message
  exit 1
}

if (-not $secret) {
  Write-Host 'Gateway secret: missing from .env.local/.env' -ForegroundColor Yellow
  exit 0
}

try {
  $headers = @{ 'x-gateway-secret' = $secret }
  $result = Invoke-RestMethod `
    -Uri $gatewayUrl `
    -Method Post `
    -Headers $headers `
    -ContentType 'application/json' `
    -Body $requestBody

  Write-Host 'Gateway command check: OK' -ForegroundColor Green
  Write-Host "Decision: $($result.decision)"
  Write-Host "Speech: $($result.speech)"
} catch {
  Write-Host 'Gateway command check: FAILED' -ForegroundColor Red
  Write-Host $_.Exception.Message
  exit 1
}
