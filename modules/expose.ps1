$logPath = "$env:ROOT\serveo_logs.log"
$errPath = "$env:ROOT\serveo_error.log"
$port = $null
$process_id = $null

function Start-ForwardingProcess {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -Command `" ssh -o StrictHostKeyChecking=no -R 80:localhost:$port serveo.net 1> $($logPath) 2>$($errPath) `"" -PassThru | Select-Object -ExpandProperty Id
}

function Restart-ForwardingProcess {
    Stop-Process -Id $process_id
    Start-ForwardingProcess
}

function Start-Forwarding {
    param(
        [Parameter(Mandatory = $true)]
        [int] $port 
    )

    Write-Host "INFO: Exposing server to internet..."
    
    $script:port = $port

    if (Test-Path $logPath) { Remove-Item $logPath -Force }
    
    try {
        $script:process_id = Start-ForwardingProcess

        do {            
            if ($ticks++ -gt 20) {
                $err = (Get-Content -Path $errPath -ErrorAction SilentlyContinue -Raw)
                if ($err -and $err.Contains("Could not resolve hostname") -and $tries++ -lt 3) { 
                    if ((Assert-Connection)) { 
                        $script:process_id = Restart-ForwardingProcess
                    }
                    $ticks = 0
                }
            }

            Start-Sleep -Milliseconds 250
            $hasToken = (Get-Content -Path $logPath -ErrorAction SilentlyContinue) -match "https:\/\/([a-f0-9]+)\.serveo\.net" 
        } while (-not $hasToken)

        Write-Host "INFO: Server successfully exposed to internet.`nINFO: Available in $($matches[0])"
    
        return @{
            process_id = $process_id
            token      = $matches[1]
            url        = $matches[0]
        }
    }
    catch {
        Write-Warning ""
        Write-Warning "There was an error while trying to expose your local server to the internet."
        Write-Warning "Try again in a few seconds..."
        Write-Warning "For more details, check the logs in:"
        Write-Warning $logPath
        Write-Warning $errPath
        return $null
    }
}