function Get-LocalIPV4Address {
    return (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
            $_.IPAddress -ne '127.0.0.1' -and 
            ($_.IPAddress -match '^10\.' -or 
            $_.IPAddress -match '^172\.(1[6-9]|2[0-9]|3[0-1])\.' -or 
            $_.IPAddress -match '^192\.168\.') 
        }).IPAddress
}

function Test-Privileges {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Assert-Connection {
    Write-Host "INFO: Checking internet connection..."
    if (-not (Test-Connection 8.8.8.8 -ErrorAction SilentlyContinue -Quiet)) {
        Write-Warning "No internet connection."
        Write-Warning "Connect to the internet, then try again."
        return $false
    } else {
        return $true
    }
}