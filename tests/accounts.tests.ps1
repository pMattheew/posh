# untestable methods:
# removeNotDefaultAccounts
# activateAdmin

BeforeAll {
    . "$PSScriptRoot\..\utils\object-helper.ps1"
    . "$PSScriptRoot\..\modules\accounts.ps1"

    $env:ADMIN_PASSWORD = "test_password"
}

Describe "Accounts" {
    It "should get admin user" {
        $u = $accounts.admin()
        $null -eq $u | Should -BeFalse
        $u.SID | Should -Match "-500"
    }

    It "should hash and unhash passwords" {
        $hash = $accounts.hash()

        $accounts.revertHash($hash) | Should -Be $env:ADMIN_PASSWORD
        
        $pswd = "test_password_2"

        $hash = $accounts.hash($pswd)

        $accounts.revertHash($hash) | Should -Be $pswd
    }
}
