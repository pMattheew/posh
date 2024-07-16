$session = [PSCustomObject]@{}

Add-Method $session "getLocalhost" {
    return (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
        $_.IPAddress -ne '127.0.0.1' -and 
        ($_.IPAddress -match '^10\.' -or 
        $_.IPAddress -match '^172\.(1[6-9]|2[0-9]|3[0-1])\.' -or 
        $_.IPAddress -match '^192\.168\.') 
    }).IPAddress
}

Add-Method $session "isAdmin" {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $user = New-Object Security.Principal.WindowsPrincipal $user 
    $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

Add-Method $session "hasInternetConnection" {
    Write-Host "INFO: Checking internet connection..."
    if (-not (Test-Connection 8.8.8.8 -ErrorAction SilentlyContinue -Quiet)) {
        Write-Warning "No internet connection."
        Write-Warning "Connect to the internet, then try again."
        return $false
    } else {
        return $true
    }
}