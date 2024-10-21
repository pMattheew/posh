$exec_time = Get-Date -Format "yyyyMMdd_HHmmss"
$expose = [PSCustomObject]@{
    port = 1100
    process          = [PSCustomObject]@{
        id    = $null
        token = $null
        url   = $null
    }
    output           = @{
        std = "$env:ROOT\serveo_logs-$($exec_time).log"
        err = "$env:ROOT\serveo_error-$($exec_time).log"
    }
    SERVEO_URL_REGEX = "https:\/\/([a-f0-9]+)\.serveo\.net"
}

Add-Method $expose.process "start" {
    return Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-WindowStyle Hidden -Command `"ssh -o StrictHostKeyChecking=no -R 80:localhost:$($expose.port) serveo.net 1> $($expose.output.std) 2>$($expose.output.err) `"" `
        -PassThru | Select-Object -ExpandProperty Id
}

Add-Method $expose.process "restart" {
    Stop-Process -Id $expose.process.id
    return $expose.process.start()    
}

Add-Method $expose.process "matchToken" {
    do {            
        if ($ticks++ -gt 20) {
            $err = (Get-Content -Path $expose.output.err -ErrorAction SilentlyContinue -Raw)
            if ($err -and $err.Contains("Could not resolve hostname") -and $tries++ -lt 3) { 
                if (($session.hasInternetConnection())) { 
                    $expose.process.id = $expose.process.restart()
                }
                $ticks = 0
            }
        }

        Start-Sleep -Milliseconds 250
        $hasToken = (Get-Content -Path $expose.output.std -ErrorAction SilentlyContinue) -match $expose.SERVEO_URL_REGEX
    } while (-not $hasToken)
    return $matches
}

Add-Method $expose "init" {
    Write-Host "INFO: Exposing server to internet..."

    if (Test-Path $expose.output.std) { Remove-Item $expose.output.std -Force }
    if (Test-Path $expose.output.err) { Remove-Item $expose.output.err -Force }
    
    try {
        $expose.process.id = $expose.process.start()

        $match = $expose.process.matchToken()

        $expose.process.url = $match[0]
        $expose.process.token = $match[1]

        Write-Host "INFO: Server successfully exposed to internet.`nINFO: Available in $($expose.process.url)"
    
        return $expose.process
    }
    catch {
        Write-Warning $_
        Write-Warning "There was an error while trying to expose your local server to the internet."
        Write-Warning "Try again in a few seconds..."
        Write-Warning "For more details, check the logs in:"
        Write-Warning $expose.output.std
        Write-Warning $expose.output.err
        return $null
    }
}