BeforeAll {
    . "$PSScriptRoot\..\utils\object-helper.ps1"
    . "$PSScriptRoot\..\modules\domain.ps1"
}

Describe "Domain" {
    It "should return if it is joined" {
        $result = $domain.joined()
        $result -eq $false -or $result -eq $app.config.domain_name |
        Should -BeTrue
    }

    Context "enter domain" {
        BeforeAll {
            $computerName = "TestComputer"

            Mock Get-Credential {
                return New-Object System.Management.Automation.PSCredential (
                    "dummyUser", (ConvertTo-SecureString "dummyPassword" -AsPlainText -Force)
                )
            }
        
            Mock Add-Computer { }
        }

        It "restarting the computer" {
            $result = $domain.enter($computerName, $true)
            
            Should -Invoke -CommandName Add-Computer -Times 1 
            
            [string]::IsNullOrEmpty($result) | Should -BeFalse
        }
    
        It "not restarting the computer" {
            $result = $domain.enter($computerName)
            
            Should -Invoke -CommandName Add-Computer -Times 1

            [string]::IsNullOrEmpty($result) | Should -BeFalse
        }
    
        It "should throw a custom error message" {
            Mock Add-Computer {
                throw "Simulated Add-Computer error"
            }
            
            { $domain.enter($computerName, $false) } | Should -Throw "*ERROR: There was an error trying to enter the '$($app.config.domain_name)' domain:*"
        }
    }
}