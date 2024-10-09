$env:EVENT_SERVER_EXPOSED = "ServerExposed"

function Send-Event {
    param(
        [Parameter(Mandatory = $true)]
        [string] $eventName,
        [pscustomobject] $payload = $null
    )

    if ($payload) { $payload = $payload | ConvertTo-Json }

    Start-Job -ArgumentList $eventName, $payload -ScriptBlock {
        param($eventName, $payload)

        # Send the event with (or without) the payload
        $e = New-Object System.IO.Pipes.NamedPipeServerStream($eventName, [System.IO.Pipes.PipeDirection]::Out)
        $writer = New-Object System.IO.StreamWriter($e)
        $e.WaitForConnection()
    
        # Write the serialized data (payload) or empty string if no payload
        $writer.Write($payload)
        $writer.Flush()
        $writer.Close()
        $e.Close()
    } > $null
}

function Receive-Event {
    param(
        [Parameter(Mandatory = $true)]
        [string] $eventName
    )
    # Receive the event and payload
    $c = New-Object System.IO.Pipes.NamedPipeClientStream(".", $eventName, [System.IO.Pipes.PipeDirection]::In)
    $c.Connect()

    $reader = New-Object System.IO.StreamReader($c)
    $jsonPayload = $reader.ReadToEnd()
    $reader.Close()
    $c.Close()

    # If there's no payload (empty string), return $null
    if ([string]::IsNullOrWhiteSpace($jsonPayload)) {
        return $null
    }

    # Deserialize the JSON payload back to a PSCustomObject
    $payload = $jsonPayload | ConvertFrom-Json

    # Return the payload
    return $payload
}