
Describe "Session" {
    BeforeAll {
        . "$PSScriptRoot\..\utils\object-helper.ps1"
        . "$PSScriptRoot\..\modules\session.ps1"

        Mock Test-Connection { }
    }

    It "Should return local IPV4 address" {
        $result = [string]::IsNullOrEmpty($session.getLocalhost())
        return -not $result | Should -BeTrue
    }

    It "Should return current user privilege" {
        $session.isAdmin() -is [boolean] | Should -BeTrue
    }

    It "Should return if there is internet connection" {
        $session.hasInternetConnection() -is [boolean] | Should -BeTrue
    }
}