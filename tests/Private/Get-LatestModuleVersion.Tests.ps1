#Requires -RunAsAdministrator
#Requires -Version 5.0
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

Describe "Get-LatestModuleVersion" {
    BeforeAll {
        
        $pester = Get-Module Pester -ListAvailable
        $latestVersion = ($pester | Sort-Object Version -Descending | Select-Object -First 1).Version.ToString()

        if ($pester.count -lt 2)
        {
            Set-PackageSource -Name PSGallery -Trusted -Force
            Install-Module -Name Pester -Repository PSGallery -Force -Confirm:$false        
        }
    }

    Context 'Input' {
        It 'SingleInput_Should_Not_Throw' {
            {Get-LatestModuleVersion -Name 'Pester'} | Should Not Throw
        }
        It 'Should_Return_Count_1' {
            (Get-LatestModuleVersion -Name Pester).Count | Should BeExactly 1
        }
        It 'MultipleInputs_Should_Not_Throw' {
            {Get-LatestModuleVersion -Name Pester} | Should Not Throw
        }
        It 'Should_Return_Count_2' {
            (Get-LatestModuleVersion -Name Pester,PackageManagement).Count | Should BeExactly 2
        }
    }

    Context 'Execution' {

    }

    Context 'Output' {
        It "Result_ShouldBe_$latestVersion" {
            Get-LatestModuleVersion -Name Pester | should be $latestVersion
        }
        It 'Result_ShouldBe_Array' {
            (Get-LatestModuleVersion -Name Pester,PackageManagement) -is [System.Array]| Should be $true
        }
        It "Result[0]_ShouldBe_$latestVersion" {
            (Get-LatestModuleVersion -Name Pester,PackageManagement)[0] | should be $latestVersion
        }
    }
}