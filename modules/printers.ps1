$printers = [PSCustomObject]@{}

Add-Method $printers "add" {
    param(
        [Parameter(Mandatory)]
        [string] $printer
    )
    Add-Printer -ConnectionName "\\$($env:PRINTER_SERVER)\$printer" -ErrorAction Stop
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
    if ($env:PRINTER_SERVER) {
        $remote = Get-Printer -ComputerName $env:PRINTER_SERVER | ForEach-Object { $_.Name }
    }
    else {
        $remote = @()
    }
    $local = Get-Printer | ForEach-Object { $_.Name }
    $available = $remote | Where-Object { $local -notcontains "\\$($env:PRINTER_SERVER)\$_" }
    if ($null -eq $available) {
        return $null
    }
    else {
        return $available
    }
}