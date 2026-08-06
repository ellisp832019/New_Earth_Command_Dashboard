param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Split-Path -Parent $scriptDir
$envFile = Join-Path $moduleRoot '.env.local'
$fallbackEnvFile = Join-Path $moduleRoot '.env'
$outputPath = Join-Path $moduleRoot 'alexa_skill\lambda_node\.lambda-env.local.json'

function Get-DotEnvMap {
  param([string]$Path)

  $values = @{}
  if (-not (Test-Path $Path)) {
    return $values
  }

  foreach ($line in Get-Content -Path $Path) {
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith('#')) {
      continue
    }

    $separatorIndex = $trimmed.IndexOf('=')
    if ($separatorIndex -lt 1) {
      continue
    }

    $name = $trimmed.Substring(0, $separatorIndex).Trim()
    $value = $trimmed.Substring($separatorIndex + 1).Trim()
    $values[$name] = $value
  }

  return $values
}

$values = Get-DotEnvMap -Path $envFile
if ($values.Count -eq 0) {
  $values = Get-DotEnvMap -Path $fallbackEnvFile
}

if (-not $values.ContainsKey('NEW_EARTH_VOICE_GATEWAY_SECRET')) {
  throw 'Could not find NEW_EARTH_VOICE_GATEWAY_SECRET in .env.local or .env.'
}

$payload = [ordered]@{
  NEW_EARTH_GATEWAY_URL = if ($values.ContainsKey('NEW_EARTH_GATEWAY_URL')) {
    $values['NEW_EARTH_GATEWAY_URL']
  } else {
    'http://127.0.0.1:8088/voice/command'
  }
  NEW_EARTH_VOICE_GATEWAY_SECRET = $values['NEW_EARTH_VOICE_GATEWAY_SECRET']
}

$directory = Split-Path -Parent $outputPath
New-Item -ItemType Directory -Force -Path $directory | Out-Null
$payload | ConvertTo-Json | Set-Content -Path $outputPath -Encoding UTF8

Write-Host "Alexa Lambda env file updated: $outputPath"
Write-Host ''
Write-Host 'Use these same values in the Alexa Lambda environment variables:' -ForegroundColor Cyan
Write-Host "NEW_EARTH_GATEWAY_URL=$($payload.NEW_EARTH_GATEWAY_URL)"
Write-Host "NEW_EARTH_VOICE_GATEWAY_SECRET=$($payload.NEW_EARTH_VOICE_GATEWAY_SECRET)"
