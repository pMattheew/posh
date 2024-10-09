param(
    [string] $task
)

if (-not (Get-Alias tsk -ErrorAction SilentlyContinue)) {
    Set-Alias -Name tsk -Value "$PSScriptRoot/tasks.ps1" -Scope Global
    Write-Host "`nNow you can use `"tsk`" to run tasks."
}

if (-not (Test-Path ".env")) { cp .env.example .env; Write-Host "Copied .env.example to .env" }

function Test { Invoke-Pester -Path .\tests -Output Detailed -ExcludeTag "e2e" }
function TestE2E { Invoke-Pester -Path .\tests -Output Detailed }
function LocalTest { "$PSScriptRoot\app-example.ps1" | Invoke-Expression }

switch ($task.ToUpper()) {
    { $_ -in 'T', 'TEST' } { Test; break }
    { $_ -in 'T:E2E', 'TEST:E2E'} { TestE2E; break }
    { $_ -in 'DEV', 'LT', 'LOCALTEST'} { LocalTest; break }
    Default { echo "`nUsage: tsk task`n" }
}