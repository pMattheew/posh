# untestable methods:
# removeNotDefaultAccounts
# activateAdmin

BeforeAll {
    . "$PSScriptRoot\..\utils\object-helper.ps1"
    . "$PSScriptRoot\..\modules\accounts.ps1"

    $global:app = @{
        config = @{
            admin_password = "test_password"
        }
    }

}

Describe "Accounts" {
    It "should get admin user" {
        $u = $accounts.admin()
        $null -eq $u | Should -BeFalse
        $u.SID | Should -Match "-500"
    }

    It "should hash and unhash passwords" {
        $hash = $accounts.hash()

        $accounts.revertHash($hash) | Should -Be $app.config.admin_password
        
        $pswd = "test_password_2"

        $hash = $accounts.hash($pswd)

        $accounts.revertHash($hash) | Should -Be $pswd
    }
}
