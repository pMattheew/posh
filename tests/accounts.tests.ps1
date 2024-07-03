# untestable methods:
# removeNotDefaultAccounts
# activateAdmin

BeforeAll {
    . "$PSScriptRoot\..\utils\object-helper.ps1"
    . "$PSScriptRoot\..\modules\accounts.ps1"

}

Describe "Accounts" {
    It "should get admin user" {
        $u = $accounts.admin()
        $null -eq $u | Should -BeFalse
        $u.SID | Should -Match "-500"
    }

    It "should hash and unhash passwords" {
        $accounts.admin_password = "test_password"

        $hash = $accounts.hash()

        $accounts.revertHash($hash) | Should -Be $accounts.admin_password
        
        $pswd = "test_password_2"

        $hash = $accounts.hash($pswd)

        $accounts.revertHash($hash) | Should -Be $pswd
    }
}
