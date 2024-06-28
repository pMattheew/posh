$domain = [PSCustomObject]@{
    name = "your-domain"
}

Add-Method $domain "isJoined" {
    $cs = Get-WmiObject -Class Win32_ComputerSystem
    if ($cs.domain -eq $domain.name) { return $domain.name } else { return $false }
}

Add-Method $domain "enter" {
    param(
        [Parameter(Mandatory)]
        [string] $computerName,
        [bool] $restart = $false
    )
    
    $params = @{
        DomainName = $domain.name
        Credential = Get-Credential
        Force      = $true
        NewName    = $computerName
    }

    try {
        if ($restart) { Add-Computer @params -Restart }
        else { Add-Computer @params }
        $result = "The '$($params.NewName)' computer now is part of '$($domain.name)'."
        if (-not $restart) { $result += "`nRestart the computer for it to take effect." }
        return $result
    }
    catch {
        throw "ERROR: There was an error trying to enter the '$($domain.name)' domain: `n$_`n"
    }
}