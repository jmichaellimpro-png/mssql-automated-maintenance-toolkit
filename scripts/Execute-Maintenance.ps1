[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ServerInstance = "localhost",

    [Parameter(Mandatory = $true)]
    [string]$DatabaseName,

    [Parameter(Mandatory = $false)]
    [string]$LogDirectory = "C:\DBA_Maintenance\Logs"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $LogDirectory "Maintenance_$($DatabaseName)_$Timestamp.log"

function Write-Log {
    param ([string]$Message)$FormattedMsg = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -$Message"
    Write-Output $FormattedMsg
    Add-Content -Path $LogFile -Value$FormattedMsg
}

Write-Log "Starting Maintenance Engine for Database [$DatabaseName] on [$ServerInstance]..."

$ScriptDir = Split-Path -Parent$MyInvocation.MyCommand.Path
$SqlShrinkScript = Join-Path (Split-Path$ScriptDir) "sql\02_truncate_and_shrink.sql"
$SqlIndexScript  = Join-Path (Split-Path$ScriptDir) "sql\03_index_maintenance.sql"

try {
    Write-Log "Step 1: Running Log Truncation & Shrink File..."
    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $DatabaseName -InputFile$SqlShrinkScript -QueryTimeout 600 -Verbose 4>&1 | Out-Null
    Write-Log "Step 1 completed successfully."

    Write-Log "Step 2: Executing Smart Index Maintenance..."
    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $DatabaseName -InputFile$SqlIndexScript -QueryTimeout 1800 -Verbose 4>&1 | Out-Null
    Write-Log "Step 2 completed successfully."

    Write-Log "Database maintenance completed without errors."
}
catch {
    Write-Log "CRITICAL FAILURE: $_"
    exit 1
}
