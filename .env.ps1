$env:APP_NAME = "Pwsh"
$env:ROOT = "$(($env:PSModulePath -Split ';')[0])\$env:APP_NAME"

if (-not (Test-Path $env:ROOT)) {
    New-Item -Path $env:ROOT -ItemType Directory > $null
}

$envFilePath = ".env"
if (Test-Path $envFilePath) {
    Get-Content $envFilePath | ForEach-Object {

        $parts = $_ -split '='
        if ($parts.Length -eq 2) {
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()
            Set-Item -Path "env:$key" -Value $value
        }
    }
}
else {
    Write-Error "The .env file does not exist." -ForegroundColor Red
}
