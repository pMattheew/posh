$env:ROOT = "$(($env:PSModulePath -Split ';')[0])\Posh"

if (-not (Test-Path $env:ROOT)) {
    New-Item -Path $env:ROOT -ItemType Directory > $null
}