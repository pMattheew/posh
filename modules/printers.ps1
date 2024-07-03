$printers = [PSCustomObject]@{
    server = "your-printer-server"
}

Add-Method $printers "format" {
    param(
        [Parameter(Mandatory)]
        [object] $obj
    )
    $r = $obj | Select-Object -Property ShareName, ComputerName, PrinterStatus
    return ConvertTo-SnakeCase $r
}

Add-Method $printers "getInstalled" { 
    param([bool] $format = $true)
    $result = Get-Printer | Where-Object { $_.Type -eq "Connection" }
    if ($format) { $printers.format($result) } else { $result }
}

Add-Method $printers "getAvailable" {
    if ($printers.server) {
        $remote = Get-Printer -ComputerName $printers.server | ForEach-Object { $_.Name }
    }
    else {
        $remote = @()
    }
    $local = Get-Printer | ForEach-Object { $_.Name }
    $available = $remote | Where-Object { $local -notcontains "\\$($printers.server)\$_" }
    if ($null -eq $available) {
        return $null
    }
    else {
        return $available
    }
}