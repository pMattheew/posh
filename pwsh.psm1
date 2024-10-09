. "$PSScriptRoot\bootstrap.ps1"

function Get-Pwsh { 
    if (-not ($session.isAdmin())) {
        Write-Host "`n$env:APP_NAME needs administrator privileges to be run.`nTry opening it again from a PowerShell instance with administrator privileges.`n"
        exit
    }
    $app 
}

Export-ModuleMember -Function Get-Pwsh