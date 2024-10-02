Describe "App" {
    It "should initialize" {
        "$PSScriptRoot\..\bootstrap.ps1" | Invoke-Expression 
        $app | Should -Not -BeNullOrEmpty
    }
}