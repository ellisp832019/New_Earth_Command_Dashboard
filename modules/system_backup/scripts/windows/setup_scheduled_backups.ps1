param()

$ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json"
$ExampleConfigPath = Join-Path $ModuleRoot "config\backup_paths.local.json.example"

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

function Get-TaskDateTime([string]$Value) {
  $Parsed = [datetime]::MinValue
  if (-not [datetime]::TryParseExact($Value.Trim(), 'HH:mm', $null, [Globalization.DateTimeStyles]::None, [ref]$Parsed)) {
    $Parsed = [datetime]::ParseExact('02:00', 'HH:mm', $null)
  }

  $Today = (Get-Date).Date
  return $Today.AddHours($Parsed.Hour).AddMinutes($Parsed.Minute)
}

function Get-TaskArgument([string]$Mode) {
  $ScriptPath = Join-Path $ModuleRoot 'scripts\windows\new_earth_backup_guardian.ps1'
  return '-NoProfile -ExecutionPolicy Bypass -File "{0}" -Mode {1}' -f $ScriptPath, $Mode
}

function Register-LocalTask(
  [string]$TaskName,
  [string]$Description,
  [string]$Mode,
  [System.DateTime]$TriggerTime,
  [ValidateSet('Daily','Weekly','Monthly')]
  [string]$ScheduleKind,
  [DayOfWeek]$DaysOfWeek = [DayOfWeek]::Sunday,
  [int]$DayOfMonth = 1
) {
  if ($ScheduleKind -eq 'Monthly') {
    $Service = New-Object -ComObject 'Schedule.Service'
    $Service.Connect()

    $Folder = $Service.GetFolder('\')
    $Definition = $Service.NewTask(0)
    $Definition.RegistrationInfo.Description = $Description
    $Definition.RegistrationInfo.Author = 'New Earth Backup Guardian'
    $Definition.Settings.StartWhenAvailable = $true
    $Definition.Settings.DisallowStartIfOnBatteries = $false
    $Definition.Settings.StopIfGoingOnBatteries = $false
    $Definition.Principal.UserId = $env:USERNAME
    $Definition.Principal.LogonType = 3
    $Definition.Principal.RunLevel = 0

    $Trigger = $Definition.Triggers.Create(4)
    $Trigger.StartBoundary = $TriggerTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
    $Trigger.Enabled = $true
    $Trigger.DaysOfMonth = $DayOfMonth
    $Trigger.MonthsOfYear = 4095

    $Action = $Definition.Actions.Create(0)
    $Action.Path = 'powershell.exe'
    $Action.Arguments = Get-TaskArgument -Mode $Mode

    $null = $Folder.RegisterTaskDefinition($TaskName, $Definition, 6, $null, $null, 3)
    return $true
  }

  $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument (Get-TaskArgument -Mode $Mode)

  $Trigger = switch ($ScheduleKind) {
    'Daily' { New-ScheduledTaskTrigger -Daily -At $TriggerTime; break }
    'Weekly' { New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DaysOfWeek -At $TriggerTime; break }
  }

  $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
  $Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries

  Register-ScheduledTask -TaskName $TaskName -Description $Description -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force | Out-Null
  return $true
}

$Schedule = Get-ConfigValue $Config 'schedule' ([ordered]@{})
$DailyTime = Get-TaskDateTime ([string](Get-ConfigValue $Schedule 'daily_time' '02:00'))
$WeeklyDayText = [string](Get-ConfigValue $Schedule 'weekly_day' 'Sunday')
$MonthlyDay = [int](Get-ConfigValue $Schedule 'monthly_day' 1)
$HadErrors = $false

$WeeklyDay = [DayOfWeek]::Sunday
if (-not [DayOfWeek]::TryParse($WeeklyDayText, $true, [ref]$WeeklyDay)) {
  $WeeklyDay = [DayOfWeek]::Sunday
}

$Tasks = @(
  [ordered]@{
    TaskName = 'New Earth Backup - Daily'
    Description = 'Runs the daily backup from the local Backup Guardian config.'
    Mode = 'DailyBackup'
    Time = $DailyTime
    Kind = 'Daily'
    DayOfWeek = [DayOfWeek]::Sunday
    DayOfMonth = 1
  },
  [ordered]@{
    TaskName = 'New Earth Backup - Weekly'
    Description = 'Runs the weekly snapshot from the local Backup Guardian config.'
    Mode = 'WeeklySnapshot'
    Time = $DailyTime
    Kind = 'Weekly'
    DayOfWeek = $WeeklyDay
    DayOfMonth = 1
  },
  [ordered]@{
    TaskName = 'New Earth Backup - Monthly'
    Description = 'Runs the monthly archive from the local Backup Guardian config.'
    Mode = 'MonthlyArchive'
    Time = $DailyTime
    Kind = 'Monthly'
    DayOfWeek = [DayOfWeek]::Sunday
    DayOfMonth = $MonthlyDay
  }
)

Write-Host '=========================================='
Write-Host 'New Earth Backup Guardian - SETUP SCHEDULER'
Write-Host '=========================================='
Write-Host "Using config: $ConfigPath"
Write-Host "Daily at: $($DailyTime.ToString('HH:mm'))"
Write-Host "Weekly day: $WeeklyDayText"
Write-Host "Monthly day: $MonthlyDay"
Write-Host ''

foreach ($Task in $Tasks) {
  try {
    Register-LocalTask `
      -TaskName $Task.TaskName `
      -Description $Task.Description `
      -Mode $Task.Mode `
      -TriggerTime $Task.Time `
      -ScheduleKind $Task.Kind `
      -DaysOfWeek $Task.DayOfWeek `
      -DayOfMonth $Task.DayOfMonth | Out-Null

    Write-Host "Registered: $($Task.TaskName)"
  } catch {
    Write-Host "Failed: $($Task.TaskName)"
    Write-Host $_.Exception.Message
    $HadErrors = $true
  }
}

if (-not $HadErrors) {
  Write-Host ''
  Write-Host 'Verifying scheduled tasks...'
  try {
    & (Join-Path $PSScriptRoot 'verify_scheduled_backups.ps1')
    Write-Host 'Scheduler verification complete.'
  } catch {
    $HadErrors = $true
    Write-Host 'Scheduler verification failed.'
    Write-Host $_.Exception.Message
  }
}

Write-Host ''
if ($HadErrors) {
  Write-Host 'Scheduler setup finished with errors.'
} else {
  Write-Host 'Scheduler setup complete.'
}
Write-Host 'The tasks will run the local backup wrappers while your user session is active.'
if ($HadErrors) {
  exit 1
}
