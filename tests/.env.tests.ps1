Describe ".env.ps1" {
    BeforeAll {
        . "$PSScriptRoot\..\.env.ps1" -Path ".env.example"
    }

    It "should populate `$env with .env file" {
        $envFilePath = "$PSScriptRoot\..\.env.example"
        Get-Content $envFilePath | ForEach-Object {
            $parts = $_ -split '='
            if ($parts.Length -eq 2) {
                $key = $parts[0].Trim()
                $value = $parts[1].Trim()

                $result = Get-Item -Path "env:$key" -ErrorAction SilentlyContinue

                $result | Should -Not -BeNullOrEmpty

                $result.value | Should -BeLikeExactly $value
            }
        }
    }

    It "should create root folder" {
        (Test-Path $env:ROOT) | Should -BeTrue
    }
}