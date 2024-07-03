BeforeAll {
    . "$PSScriptRoot\..\utils\object-helper.ps1"
    . "$PSScriptRoot\..\modules\printers.ps1"

    # function Add-MockPrinter {
    #     param (
    #         [Parameter(Mandatory)]
    #         [string]$name,
    #         [Parameter(Mandatory)]
    #         [string]$port
    #     )
    
    #     if (-not (Get-PrinterPort -Name $port -ErrorAction SilentlyContinue)) {
    #         Add-PrinterPort -Name $port -PrinterHostAddress "192.168.1.100"
    #     }

    #     if (-not (Get-Printer -Name $name -ErrorAction SilentlyContinue)) {
    #         Add-Printer -Name $name -DriverName "Microsoft Print To PDF" -PortName $port
    #     }
    # }

    # function Remove-MockPrinter {
    #     param (
    #         [Parameter(Mandatory)]
    #         [string]$name,
    #         [Parameter(Mandatory)]
    #         [string]$port
    #     )
    
    #     if (Get-Printer -Name $name -ErrorAction SilentlyContinue) {
    #         Remove-Printer -Name $name
    #     }
    #     if (Get-PrinterPort -Name $port -ErrorAction SilentlyContinue) {
    #         Remove-PrinterPort -Name $port
    #     }
    # }

    # Mock -CommandName Get-Printer -MockWith {
    #     param (
    #         [string]$ComputerName
    #     )
    #     if ($null -eq $ComputerName) {
    #         Invoke-Command $PSCmdlet.MyInvocation.MyCommand.OriginalCommand
    #     }
    #     else {
    #         return @(
    #             [PSCustomObject]@{ Name = "RemotePrinter1"; Type = "Connection" },
    #             [PSCustomObject]@{ Name = "RemotePrinter2"; Type = "Connection" }
    #         )
    #     }
    # }
}

Describe "Printers" {
    It "should be defined" {
        $null -eq $printers | Should -BeFalse
    }

    # must be implemented
    # It "should get available to install" {}
    # It "should get installed" {}
}