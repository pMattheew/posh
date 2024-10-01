$domain = [PSCustomObject]@{}

Add-Method $domain "joined" {
    $cs = Get-WmiObject -Class Win32_ComputerSystem
    if ($cs.domain -eq $app.config.domain_name) { return $app.config.domain_name } else { return $false }
}

Add-Method $domain "enter" {
    param(
        [Parameter(Mandatory)]
        [string] $computerName,
        [bool] $restart = $false
    )
    
    $params = @{
        DomainName = $app.config.domain_name
        Credential = Get-Credential
        Force      = $true
        NewName    = $computerName
    }

    try {
        if ($restart) { Add-Computer @params -Restart }
        else { Add-Computer @params }
        $result = "The '$($params.NewName)' computer now is part of '$($app.config.domain_name)'."
        if (-not $restart) { $result += "`nRestart the computer for it to take effect." }
        return $result
    }
    catch {
        throw "ERROR: There was an error trying to enter the '$($app.config.domain_name)' domain: `n$_`n"
    }
}