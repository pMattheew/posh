param(
    [string] $task
)

if (-not (Get-Alias tsk -ErrorAction SilentlyContinue)) {
    Set-Alias -Name tsk -Value ./tasks.ps1 -Scope Global
    Write-Host "`nNow you can use `"tsk`" to run tasks."
}

if (-not (Test-Path ".env")) { cp .env.example .env; Write-Host "Copied .env.example to .env" }

function Test { Invoke-Pester -Path .\tests -Output Detailed }

switch ($task.ToUpper()) {
    { $_ -in 'T', 'TEST' } { Test; break }
    Default { echo "`nUsage: tsk task`n" }
}