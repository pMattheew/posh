$domain = [PSCustomObject]@{}

Add-Method $domain "joined" {
    $cs = Get-WmiObject -Class Win32_ComputerSystem
    if ($cs.domain -eq $env:DOMAIN_NAME) { return $env:DOMAIN_NAME } else { return $false }
}

Add-Method $domain "enter" {
    param(
        [Parameter(Mandatory)]
        [string] $computerName,
        [bool] $restart = $false
    )
    
    $params = @{
        DomainName = $env:DOMAIN_NAME
        Credential = Get-Credential
        Force      = $true
        NewName    = $computerName
    }

    try {
        if ($restart) { Add-Computer @params -Restart }
        else { Add-Computer @params }
        $result = "The '$($params.NewName)' computer now is part of '$($env:DOMAIN_NAME)'."
        if (-not $restart) { $result += "`nRestart the computer for it to take effect." }
        return $result
    }
    catch {
        throw "ERROR: There was an error trying to enter the '$($env:DOMAIN_NAME)' domain: `n$_`n"
    }
}