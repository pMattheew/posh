$app.get('/ping', { return "Connected" })

$app.get('/system-info', {
        $data = @{
            name               = $env:COMPUTERNAME
            domain             = (Test-Domain)
            has_admin          = (Test-Admin)
            installed_printers = (Get-InstalledPrinters)
            available_printers = (Get-AvailablePrinters)
        }

        return $data
    })

$app.post('/activate-admin', {
        try {
            Set-Admin
            return "Administrator account was activated successfully with the following credentials:`nUsername: $($adminModule.username)`nPassword: $($adminModule.password)`n" 
        }
        catch {
            return "An error ocurred while trying to activate the administrator user:`n$_"
        }
    })

$app.post('/enter-domain', {
    param(
        [object] $data
    )
    return (Enter-Domain -ComputerName $data.computer_name)
})

$app.post('/add-printers', {
    param(
        [object] $data
    )
    foreach($p in $data.printers) {
        try {
            Add-Printer -ConnectionName "\\your-printer-server\$p" -ErrorAction Stop
            $result += "`n'$p' added successfully."
        }
        catch { $result += "`nThere was an error trying to add '$p':`n$_" }
    }
    return $result
})

$app.listen()