$env:APP_NAME = "Pwsh"
$env:ROOT = "$(($env:PSModulePath -Split ';')[0])\$env:APP_NAME"

if (-not (Test-Path $env:ROOT)) {
    New-Item -Path $env:ROOT -ItemType Directory > $null
}