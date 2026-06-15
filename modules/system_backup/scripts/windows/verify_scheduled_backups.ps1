param()

$ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json"
$ExampleConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json.example"
$RuntimeDir = Join-Path $ModuleRoot "runtime"
$SchedulerStatusPath = Join-Path $RuntimeDir "scheduler_status.json"

if (!(Test-Path $RuntimeDir)) {
  New-Item -ItemType Directory -Path $RuntimeDir -Force | Out-Null
}

if (Test-Path $ConfigPath) {
  $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
} elseif (Test-Path $ExampleConfigPath) {
  $Config = Get-Content $ExampleConfigPath -Raw | ConvertFrom-Json
} else {
  throw "Backup guardian config not found. Expected either '$ConfigPath' or '$ExampleConfigPath'."
}

function Get-ConfigValue($Object, $Path, $Fallback) {
  if ($null -eq $Object) {
    return $Fallback
  }

  $Current = $Object
  foreach ($Segment in $Path.Split('.')) {
    if ($null -eq $Current) {
      return $Fallback
    }

    $Property = $Current.PSObject.Properties[$Segment]
    if ($null -eq $Property) {
      return $Fallback
    }

    $Current = $Property.Value
  }

  if ($null -eq $Current -or [string]::IsNullOrWhiteSpace([string]$Current)) {
    return $Fallback
  }

  return $Current
}

function Get-SchedulerSummary([string]$State, [int]$ReadyCount, [int]$DisabledCount, [int]$MissingCount) {
  switch ($State) {
    'green' { return 'Scheduler verified. Daily, weekly, and monthly tasks are present and enabled.' }
    'amber' { return "Scheduler is partially ready. $ReadyCount task(s) are ready, $DisabledCount disabled." }
    default { return "Scheduler verification failed. $MissingCount task(s) are missing or unavailable." }
  }
}

$Schedule = Get-ConfigValue $Config 'schedule' ([ordered]@{})
$TaskNames = @(
  'New Earth Backup - Daily',
  'New Earth Backup - Weekly',
  'New Earth Backup - Monthly'
)

$Tasks = @()
$ReadyCount = 0
$DisabledCount = 0
$MissingCount = 0
$AnyErrors = $false
$Errors = @()

foreach ($TaskName in $TaskNames) {
  $TaskState = [ordered]@{
    name = $TaskName
    exists = $false
    enabled = $false
    state = 'Missing'
    next_run = ''
    last_run = ''
    message = ''
  }

  try {
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
    $Info = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue
    $TaskState.exists = $true
    $TaskState.enabled = $Task.Settings.Enabled
    $TaskState.state = if ($Task.Settings.Enabled) { 'Ready' } else { 'Disabled' }
    if ($Info -ne $null) {
      if ($Info.NextRunTime -ne $null -and $Info.NextRunTime -ne [datetime]::MinValue) {
        $TaskState.next_run = $Info.NextRunTime.ToString('o')
      }
      if ($Info.LastRunTime -ne $null -and $Info.LastRunTime -ne [datetime]::MinValue) {
        $TaskState.last_run = $Info.LastRunTime.ToString('o')
      }
    }

    if ($Task.Settings.Enabled) {
      $ReadyCount += 1
      $TaskState.message = 'Present and enabled.'
    } else {
      $DisabledCount += 1
      $TaskState.message = 'Present but disabled.'
    }
  } catch {
    $MissingCount += 1
    $AnyErrors = $true
    $TaskState.message = $_.Exception.Message
  }

  $Tasks += [pscustomobject]$TaskState
}

$State = if ($MissingCount -gt 0 -or $AnyErrors) {
  'red'
} elseif ($DisabledCount -gt 0) {
  'amber'
} else {
  'green'
}

$Details = @(
  "Daily backup task: $($Tasks[0].state)",
  "Weekly snapshot task: $($Tasks[1].state)",
  "Monthly archive task: $($Tasks[2].state)"
)

$Warnings = @()
if ($State -eq 'amber') {
  $Warnings += 'One or more scheduled tasks exist but are disabled.'
}
if ($State -eq 'red') {
  $Warnings += 'One or more scheduled tasks could not be found or read back.'
  $Errors += 'Scheduled task verification failed.'
}

$Status = [ordered]@{
  exists = $true
  checked_at = (Get-Date).ToString('o')
  state = $State
  summary = Get-SchedulerSummary -State $State -ReadyCount $ReadyCount -DisabledCount $DisabledCount -MissingCount $MissingCount
  details = $Details
  warnings = $Warnings
  errors = $Errors
  tasks = $Tasks
  schedule = [ordered]@{
    enabled = [bool](Get-ConfigValue $Schedule 'enabled' $false)
    daily_time = [string](Get-ConfigValue $Schedule 'daily_time' '02:00')
    weekly_day = [string](Get-ConfigValue $Schedule 'weekly_day' 'Sunday')
    monthly_day = [int](Get-ConfigValue $Schedule 'monthly_day' 1)
  }
}

$Status | ConvertTo-Json -Depth 6 | Set-Content -Path $SchedulerStatusPath -Encoding UTF8

if ($State -eq 'red') {
  throw 'Scheduled task verification failed.'
}
