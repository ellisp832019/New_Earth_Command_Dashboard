param(
  [string]$Target = ".\modules\voice_intelligence"
)

New-Item -ItemType Directory -Force -Path $Target | Out-Null
Copy-Item -Recurse -Force .\docs $Target
Copy-Item -Recurse -Force .\src $Target
Copy-Item -Recurse -Force .\examples $Target
Copy-Item -Recurse -Force .\tests $Target
Write-Host "Voice Intelligence module copied to $Target"
