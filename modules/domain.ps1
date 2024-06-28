$domain = "masp.srv2"

function Test-Domain {
    $cs = Get-WmiObject -Class Win32_ComputerSystem
    if ($cs.domain -eq $domain) { return $domain } else { return $false }
}

function Enter-Domain {
    param(
        [bool] $restart = $false,
        [Parameter(Mandatory = $true)]
        [string] $computerName
    )
    
    $params = @{
        DomainName  = $domain
        Credential  = Get-Credential
        Force       = $true
        NewName     = $computerName
        ErrorAction = "Stop"
    }

    try {
        if ($restart) { Add-Computer @params -Restart }
        else { Add-Computer @params }
        $result = "The '$($params.NewName)' computer now is part of '$domain'."
        if(-not $restart) { $result += "`nRestart the computer for it to take effect." }
        return $result
    }
    catch {
        throw "ERROR: There was an error trying to enter the domain: `n$_`n"
    }
}