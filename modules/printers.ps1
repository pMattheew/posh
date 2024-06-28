. "$PSScriptRoot\..\utils\converters.ps1"

$printerServer = "your-printer-server"

Function Format-Printers {
    param(
        [object] $obj
    )
    $r = $obj | Select-Object -Property ShareName, ComputerName, PrinterStatus
    return ConvertTo-SnakeCase $r
}

function Get-InstalledPrinters {
    $printers = Get-Printer | Where-Object { $_.Type -eq "Connection" }
    return Format-Printers $printers
}

function Get-AvailablePrinters {
    $remote = Get-Printer -ComputerName $printerServer | ForEach-Object { $_.Name }
    $local = Get-Printer | ForEach-Object { $_.Name }
    $available = $remote | Where-Object { $local -notcontains "\\$printerServer\$_" }
    if ($null -eq $available) {
        return $null
    }
    else {
        return $available
    }
}