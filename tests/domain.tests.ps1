
Describe "Domain" {
    BeforeAll {
        . "$PSScriptRoot\..\utils\object-helper.ps1"
        . "$PSScriptRoot\..\modules\domain.ps1"
    }

    It "should return if it is joined" {
        $result = $domain.isJoined()
        $result -eq $false -or $result -eq $domain.name |
        Should -BeTrue
    }
}