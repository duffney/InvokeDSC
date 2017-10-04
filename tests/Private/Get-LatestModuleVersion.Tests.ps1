#Requires -Version 5.0
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

Describe "Get-LatestModuleVersion" {
    BeforeAll {
        Function Get-Module {
            param()
            throw 'Fake Get-Module cmdlet'
        }

        Mock -CommandName Get-Module {
            @([PSCustomObject]@{
                ModuleType = 'Script'
                Version = '4.0.8'
                Name = 'Pester'
                ExportedCommands = {'Describe','Context'}
            },
            [PSCustomObject]@{
                ModuleType = 'Script'
                Version = '4.0.7'
                Name = 'Pester'
                ExportedCommands = {'Describe','Context'}
            }
            )
        } -ParameterFilter {$Name -eq 'Pester'}

        Mock -CommandName Get-Module {
            [PSCustomObject]@{
                ModuleType = 'Manifest'
                Version = '3.2.0.0'
                Name = 'Pester'
                ExportedCommands = {'Convert-CIDRToSubhetMask','Test-IsNanoServer'}
            }
        } -ParameterFilter {$Name -eq 'xNetworking'}

        Mock -CommandName Get-Module {
            [PSCustomObject]@{
                ModuleType = 'Binary'
                Version = '1.0.0.1'
                Name = 'PackageManagement'
                ExportedCommands = {'Find-Package','Get-Package'}
            }
        } -ParameterFilter {$Name -eq 'PackageManagement'}
    }

    Context 'Input' {
        It 'SingleInput_Should_Not_Throw' {
            {Get-LatestModuleVersion -Name 'Pester'} | Should Not Throw
        }
        It 'Should_Return_Count_1' {
            (Get-LatestModuleVersion -Name Pester).Count | Should BeExactly 1
        }
        It 'MultipleInputs_Should_Not_Throw' {
            {Get-LatestModuleVersion -Name Pester,PackageManagement} | Should Not Throw
        }
        It 'Should_Return_Count_2' {
            (Get-LatestModuleVersion -Name Pester,PackageManagement).Count | Should BeExactly 2
        }
    }

    Context 'Execution' {
        It 'SingleModuleVersion_ShouldNot_Throw' {
            {Get-LatestModuleVersion -Name xNetworking} | should not Throw
        }
        It 'MultipleModuleVersions_ShouldNot_Throw' {
            {Get-LatestModuleVersion -Name Pester} | should not Throw
        }
    }

    Context 'Output' {
        It 'Result_ShouldBe_Array' {
            (Get-LatestModuleVersion -Name Pester,PackageManagement) -is [System.Array]| Should be $true
        }
        It "Result_ShouldBe_4.0.8" {
            Get-LatestModuleVersion -Name Pester | should be '4.0.8'
        }
        It "Result[1]_ShouldBe_1.0.0.1" {
            (Get-LatestModuleVersion -Name Pester,PackageManagement)[1] | should be '1.0.0.1'            
        }
    }
}