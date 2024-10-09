BeforeAll {
    . "$PSScriptRoot\..\tasks.ps1"
    . "$PSScriptRoot\..\bootstrap.ps1"
}

Describe "App" -Tag "e2e" {
    It "should initialize" {
        $app | Should -Not -BeNullOrEmpty
    }
    
    It "should have events" {
        $app.events | Should -Not -BeNullOrEmpty
    }
}