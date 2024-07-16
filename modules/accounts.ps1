$accounts = [PSCustomObject]@{
    admin_password = "your-wonderful-password"
}

Add-Method $accounts "admin" { Get-LocalUser | Where-Object { $_.SID -like '*-500' } }

Add-Method $accounts "isAdminActivated" { $accounts.admin().Enabled }

Add-Method $accounts "hash" { 
    param([string] $pswd = $accounts.admin_password)
    ConvertTo-SecureString -String $pswd -AsPlainText -Force 
}

Add-Method $accounts "revertHash" {
    param(
        [Parameter(Mandatory)]
        [System.Security.SecureString] $securePassword
    )

    $unmanagedString = [System.Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($securePassword)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringUni($unmanagedString)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($unmanagedString)
    }
}

Add-Method $accounts "removeNotDefaultAccounts" {
    try {
        Get-LocalUser | Where-Object { $_.Enabled -eq $true -and -not $_.SID -like '*-500' } | Remove-LocalUser
    }
    catch {
        throw "`nAn error occurred while trying to remove default accounts:`n$_`n"
    }
}

Add-Method $accounts "activateAdmin" {
    try {
        $user = $accounts.admin()
        if ($user.Enabled -eq $false) {
            Enable-LocalUser -SID $user.SID
            Set-LocalUser -SID $user.SID -Password $accounts.hash()
            $accounts.removeNotDefaultAccounts()
        }
    }
    catch {
        throw "`nAn error occurred while trying to activate the administrator account:`n$_`n"
    }
}