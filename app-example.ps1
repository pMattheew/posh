ipmo pwsh

$app = Get-Pwsh

$app.get('/ping', { return "Connected" })

$app.get('/system-info', {
        $data = @{
            name               = $env:COMPUTERNAME
            domain             = ($domain.joined())
            has_admin          = ($accounts.isAdminActivated())
            installed_printers = ($printers.getInstalled())
            available_printers = ($printers.getAvailable())
        }

        return $data
    })

$app.get('/activate-admin', {
        try {
            if ($accounts.isAdminActivated() -eq $false) {
                $accounts.activateAdmin()
                $adm = $accounts.admin()
                return "Administrator account was activated successfully with the following credentials:`nUsername: $($adm.Name)`nPassword: $($accounts.admin_password)`n" 
            }
            return "Administrator account is already activated."
        }
        catch {
            return "An error ocurred while trying to activate the administrator user:`n$_"
        }
    })

$app.post('/enter-domain', {
        param(
            [object] $data
        )
        return ($domain.enter($data.computer_name))
    })

$app.post('/add-printers', {
        param(
            [object] $data
        )
        foreach ($p in $data.printers) {
            try {
                $printers.add($p)
                $result += "`n'$p' added successfully."
            }
            catch { $result += "`nThere was an error trying to add '$p':`n$_" }
        }
        return $result
    })

$app.listen(@{
        port   = 1100
        expose = $true
    })