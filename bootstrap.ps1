. "$PSScriptRoot\.env.ps1"
. "$PSScriptRoot\utils\object-helper.ps1"
. "$PSScriptRoot\utils\converters.ps1"
. "$PSScriptRoot\modules\session.ps1"
. "$PSScriptRoot\modules\expose.ps1"
. "$PSScriptRoot\modules\accounts.ps1"
. "$PSScriptRoot\modules\domain.ps1"
. "$PSScriptRoot\modules\printers.ps1"

$app = [PSCustomObject]@{}

Add-Property $app "listener" (New-Object System.Net.HttpListener)

Add-Property $app "handlers" (New-Object System.Collections.ArrayList)

Add-Property $app "forwarding" $null

Add-Method $app "stop" {
    Write-Host "INFO: Stopping application..."
    if ($app.forwarding) {
        Stop-Process -Id $app.forwarding.id
    }
    $app.listener.stop()
}

Add-Method $app "listen" {
    param(
        [hashtable] $options = @{
            port   = $expose.port
            expose = $false
        }
    )

    $addresses = @(
        "http://*.serveo.net:$($options.port)/", 
        "http://*:$($options.port)/", 
        "http://$(($session.getLocalhost())):$($options.port)/"
    )

    for ($i = 0; $i -lt $addresses.Count; $i++) {
        $app.listener.Prefixes.Add($addresses[$i])
    }
    
    $app.listener.Start()

    Write-Host "INFO: Listening on port $($options.port)..."

    if ($options.expose) {
        $expose.port = $options.port
        $app.forwarding = $expose.init()
    }
    
    try {
        while ($app.listener.isListening) {
            $context = $app.listener.GetContextAsync() | Wait-Task
            $script:req = $context.Request
            $script:res = $context.Response
            $script:payload = $null
    
            $app.getPayload()
    
            $app.setCORSHeaders()
    
            $app.handlers.forEach({ Invoke-Command -ScriptBlock $_ })
    
            $app.handleCORSRequests()
    
            $app.returnNotFound()
        }
    }
    finally {
        $app.stop()
    }
    
}

Add-Method $app "request" {
    param(
        [Parameter(Mandatory = $true)]
        [string] $method,

        [Parameter(Mandatory = $true)]
        [string] $path,

        [Parameter(Mandatory = $true)]
        [scriptblock] $callback
    )

    $handler = @"
if (`$req.HttpMethod -eq '$($method)' -and `$req.RawUrl -eq '$($path)') {
    `$type = 'text/plain'
    `$status = 200
    
    try {
        if (`$payload) {
            `$result = Invoke-Command -ScriptBlock { $($callback) } -ArgumentList `$payload
        } else {
            `$result = Invoke-Command -ScriptBlock { $($callback) }
        }
    }
    catch { 
        `$result = `"There was an error while doing a $($method) request to '$($path)':`n`$_`" 
        Write-Warning `$result
        `$status = 500
    }
        
    if (`$null -eq `$result) {
        `$result = @{}
    }

    if (`$result -is [hashtable] -or `$result -is [object[]]) {
        `$result = `$result | ConvertTo-EnumsAsStrings | ConvertTo-Json
        `$type = 'application/json'
    }

    `$buffer = [System.Text.Encoding]::UTF8.GetBytes(`$result)
    `$res.StatusCode = `$status
    `$res.ContentType = `$type
    `$res.ContentLength64 = `$buffer.Length
    `$res.OutputStream.Write(`$buffer, 0, `$buffer.Length)
    `$res.OutputStream.Close()
}
"@

    $app.handlers.Add([scriptblock]::Create($handler)) > $null
}

Add-Method $app "getPayload" {
    $payloadSize = $req.ContentLength64
    if ($payloadSize -gt 0) {
        $buffer = New-Object byte[]($payloadSize)
        $req.InputStream.Read($buffer, 0, $payloadSize)
        $data = [System.Text.Encoding]::UTF8.GetString($buffer)
        try {
            $data = $data | ConvertFrom-Json
        }
        finally { $null }

        $script:payload = $data
    }
    return $null
}

Add-Method $app "setCORSHeaders" {
    $res.AddHeader("Access-Control-Allow-Origin", "*")
    $res.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    $res.AddHeader("Access-Control-Allow-Headers", "Content-Type, Accept, X-Requested-With")
    $res.AddHeader("Access-Control-Max-Age", "1728000")
}

Add-Method $app "handleCORSRequests" {
    if ($req.HttpMethod -eq "OPTIONS") {
        $res.StatusCode = 200
        $res.ContentType = "text/plain"
        $res.OutputStream.Close()
    }
}

Add-Method $app "returnNotFound" {
    $httpResponseWasSent = $res.ContentLength64 -gt 0
    if (-not $httpResponseWasSent) {
        $buffer = [System.Text.Encoding]::UTF8.GetBytes("Error 404: Not found.")            
        $res.StatusCode = 404
        $res.ContentType = "text/plain"
        $res.ContentLength64 = $buffer.Length
        $res.OutputStream.Write($buffer, 0, $buffer.Length)
        $res.OutputStream.Close()
    }
}

Add-Method $app "get" {
    param(
        [Parameter(Mandatory = $true)]
        [string] $path,

        [Parameter(Mandatory = $true)]
        [scriptblock] $callback
    )
    $app.request('GET', $path, $callback)
}

Add-Method $app "post" {
    param(
        [Parameter(Mandatory = $true)]
        [string] $path,

        [Parameter(Mandatory = $true)]
        [scriptblock] $callback
    )
    $app.request('POST', $path, $callback)
}