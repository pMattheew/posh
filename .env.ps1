param(
    [string] $path = ".env"
)

$env:APP_NAME = "Pwsh"
$env:ROOT = "$(($env:PSModulePath -Split ';')[0])\$env:APP_NAME"

if (-not (Test-Path $env:ROOT)) {
    New-Item -Path $env:ROOT -ItemType Directory > $null
}

if (-not (Test-Path $path)) {
    Write-Warning "The .env file does not exist."
    Write-Warning "Proceeding with a copy of .env.example. in $PSScriptRoot"
    Copy-Item "$PSScriptRoot\.env.example" ".env"
}

Get-Content $path | ForEach-Object ({
    $parts = $_ -split '='
    if ($parts.Length -eq 2) {
        $key = $parts[0].Trim()
        $value = $parts[1].Trim()
        Set-Item -Path "env:$key" -Value $value
    }
})

