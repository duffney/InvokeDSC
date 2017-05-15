$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

Describe "Get-ModuleFromConfiguration Tests" {
    
    it "command should exists" {
        Get-Command -Name Get-ModuleFromConfiguration | should not BeNullOrEmpty
    }

    Context "Single Configuration" {
        
        $result = Get-ModuleFromConfiguration -Path $PSScriptRoot\..\..\examples\xWebSite.json

        it "Count Should Be 1" {
            $result.count | should be 1
        }

        it "Should Match xWebAdministration" {
            $result | should be 'xWebAdministration'
        }
    }

    Context "Multiple Configurations" {
        $result = Get-ModuleFromConfiguration -Path $PSScriptRoot\..\..\examples -Recurse

        it "Count Should BeGreaterThan 2" {
            $result.count | should BeGreaterThan 2
        }

        it "Should match xWebAdministration|cNtfsAccessControl" {
            $result | should match ([regex]::('xWebAdministration|cNtfsAccessControl'))
        }
    }
}