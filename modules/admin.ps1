$adminModule = [PSCustomObject]@{}

Add-Property $adminModule "username" "Administrator"
Add-Property $adminModule "password" "your-wonderful-password"
Add-Property $adminModule "hash" (ConvertTo-SecureString -String $adminModule.password -AsPlainText -Force)

function Test-Admin {
    $a = Get-LocalUser -Name $adminModule.username
    return $a.Enabled
}

function Remove-NotDefaultAccounts {
    try {
        Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.Name -ne $adminModule.username } | Remove-LocalUser
    }
    catch {
        throw "`nAn error occurred while trying to remove default accounts:`n$_`n"
    }
}

function Set-Admin {
    try {
        $a = Get-LocalUser -Name $adminModule.username

        if ($null -eq $a) {
            $a = New-LocalUser -Name $adminModule.username -Password $adminModule.hash -FullName $adminModule.username -Description "Administrator account"
        }
        else {
            Enable-LocalUser -Name $adminModule.username
            Set-LocalUser -Name $adminModule.username -Password $adminModule.hash
        }

        Remove-NotDefaultAccounts
    }
    catch {
        throw "`nAn error occurred while trying to set the administrator account:`n$_`n"
    }
}