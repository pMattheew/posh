BeforeAll {
    "$PSScriptRoot\..\tasks.ps1" | Invoke-Expression
}

Describe "App" -Tag "e2e" {
    It "should initialize" {
        "$PSScriptRoot\..\bootstrap.ps1" | Invoke-Expression 
        $app | Should -Not -BeNullOrEmpty
    }
}