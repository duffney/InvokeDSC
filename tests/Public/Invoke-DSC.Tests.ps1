#Requires -Version 5.0
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

Describe 'Invoke-Dsc Tests' {
    function Get-LatestModuleVersion () {}
    function ConvertTo-Dsc () {}

    Context 'Inputs' {
        Mock Get-DscLocalConfigurationManager {'Idle'}
        Mock Get-LatestModuleVersion {'8.0.0.0'}
        Mock ConvertTo-Dsc {
            [PSCustomObject]@{
                ResourceName = 'DevOpsGroup'
                dscResourceName = 'xGroup'
                ModuleName = 'xPSDesiredStateConfiguration'
                ModuleVersion = '8.0.0.0'
                Property = @{
                    ensure = 'Present'
                    GroupName = 'DevOps'
                }
            }
        }
        Mock Invoke-DscResource {} -ParameterFilter {$Method -eq 'Test'}
        Mock Invoke-DscResource {} -ParameterFilter {$Method -eq 'Set'}

        $config = @"
{
    "Modules":{
            "xPSDesiredStateConfiguration":'8.0.0.0'
    },
    "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
    }
}
"@

        It 'ShouldProcess -Whatif' {
            $resource = ConvertTo-Dsc -InputObject $config
            Invoke-Dsc -Resource $resource -WhatIf
            Assert-MockCalled Invoke-DscResource -Times 1 -ParameterFilter {$Method -eq 'Test'}
            Assert-MockCalled Invoke-DscResource -Times 0 -ParameterFilter {$Method -eq 'Set'}
        }
        It 'Should_Invoke_Set_Method' {
            $resource = ConvertTo-Dsc -InputObject $config
            Invoke-Dsc -Resource $resource
            Assert-MockCalled Invoke-DscResource -Times 1 -ParameterFilter {$Method -eq 'Test'}
            Assert-MockCalled Invoke-DscResource -Times 1 -ParameterFilter {$Method -eq 'Set'}
        }
        It 'ModuleVersionInConfig_Should_Not_Call_Get-LatestModuleVersion' {
            $resource = ConvertTo-Dsc -InputObject $config
            Invoke-Dsc -Resource $resource
            Assert-MockCalled Get-LatestModuleVersion -Times 0
        }
        It 'ModuleVersionNull_Should_Call_Get-LatestModuleVersion' {
            $resource = ConvertTo-Dsc -InputObject $config
            $resource.ModuleVersion = $null
            Invoke-Dsc -Resource $resource
            Assert-MockCalled Get-LatestModuleVersion -Times 1
        }
        It 'LCMState_Idle_AssertMock_Get-DSCLocalConfigurationManager_1_Time' {
            $resource = ConvertTo-Dsc -InputObject $config
            Invoke-Dsc -Resource $resource
            Assert-MockCalled Get-DscLocalConfigurationManager -Times 1
        }
    }
    Context 'Execute_TestMethod_Pass' {

        Mock Get-DscLocalConfigurationManager {'Idle'}
        Mock Get-LatestModuleVersion {'8.0.0.0'}
        Mock ConvertTo-Dsc {
            [PSCustomObject]@{
                ResourceName = 'DevOpsGroup'
                dscResourceName = 'xGroup'
                ModuleName = 'xPSDesiredStateConfiguration'
                ModuleVersion = '8.0.0.0'
                Property = @{
                    ensure = 'Present'
                    GroupName = 'DevOps'
                }
            }
        }
        Mock Invoke-DscResource {
            [PSCustomObject]@{
                InDesiredState = $true
            }
        } -ParameterFilter {$Method -eq 'Test'}
        Mock Invoke-DscResource {} -ParameterFilter {$Method -eq 'Set'}

        $config = @"
{
    "Modules":{
            "xPSDesiredStateConfiguration":'8.0.0.0'
    },
    "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
    }
}
"@
        It 'TestMethod_Pass_Should_Not_Invoke_Set' {
            $resource = ConvertTo-Dsc -InputObject $config
            Invoke-Dsc -Resource $resource
            Assert-MockCalled Invoke-DscResource -Times 1 -ParameterFilter {$Method -eq 'Test'}
            Assert-MockCalled Invoke-DscResource -Times 0 -ParameterFilter {$Method -eq 'Set'}
        }
    }
    Context 'Execute_TestMethod_Fail' {
        Mock Get-DscLocalConfigurationManager {'idle'}
        Mock Get-LatestModuleVersion {'8.0.0.0'}
        Mock ConvertTo-Dsc {
            [PSCustomObject]@{
                ResourceName = 'DevOpsGroup'
                dscResourceName = 'xGroup'
                ModuleName = 'xPSDesiredStateConfiguration'
                ModuleVersion = '8.0.0.0'
                Property = @{
                    ensure = 'Present'
                    GroupName = 'DevOps'
                }
            }
        }
        Mock Invoke-DscResource {
            [PSCustomObject]@{
                InDesiredState = $false
            }
        } -ParameterFilter {$Method -eq 'Test'}
        Mock Invoke-DscResource {} -ParameterFilter {$Method -eq 'Set'}

        $config = @"
{
    "Modules":{
            "xPSDesiredStateConfiguration":'8.0.0.0'
    },
    "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
    }
}
"@
        It 'TestMethod_Fail_Should_Invoke_Set' {
            $resource = ConvertTo-Dsc -InputObject $config
            Invoke-Dsc -Resource $resource
            Assert-MockCalled Invoke-DscResource -Times 1 -ParameterFilter {$Method -eq 'Test'}
            Assert-MockCalled Invoke-DscResource -Times 1 -ParameterFilter {$Method -eq 'Set'}
        }
    }
    Context 'Execute_ResourceNotFound_Error' {
        Mock Get-DscLocalConfigurationManager {'idle'}
        Mock Get-LatestModuleVersion {'8.0.0.0'}
        Mock ConvertTo-Dsc {
            [PSCustomObject]@{
                ResourceName = 'DevOpsGroup'
                dscResourceName = 'xGroup'
                ModuleName = 'xPSDesiredStateConfiguration'
                ModuleVersion = '8.0.0.0'
                Property = @{
                    ensure = 'Present'
                    GroupName = 'DevOps'
                }
            }
        }
        Mock Invoke-DscResource {throw 'Invoke-DscResource : Resource File was not found.'}

        $config = @"
{
    "Modules":{
            "xPSDesiredStateConfiguration":'8.0.0.0'
    },
    "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
    }
}
"@
        It 'Resource_Not_Found_Should_Throw' {
            $resource = ConvertTo-Dsc -InputObject $config
            {Invoke-Dsc -Resource $resource} | Should -Throw 'Invoke-DscResource : Resource File was not found.'

        }
    }

    Context 'Execute_LCM_Busy' {
        Mock Get-DscLocalConfigurationManager {
            [PSCustomObject]@{
                LCMState = 'Busy'
            }
        }
        Mock Get-LatestModuleVersion {'8.0.0.0'}
        Mock ConvertTo-Dsc {
            [PSCustomObject]@{
                ResourceName = 'DevOpsGroup'
                dscResourceName = 'xGroup'
                ModuleName = 'xPSDesiredStateConfiguration'
                ModuleVersion = '8.0.0.0'
                Property = @{
                    ensure = 'Present'
                    GroupName = 'DevOps'
                }
            }
        }
        Mock Invoke-DscResource {} -ParameterFilter {$Method -eq 'Test'}
        Mock Invoke-DscResource {} -ParameterFilter {$Method -eq 'Set'}

        It 'LCMState_Busy_AssertMock_Get-DSCLocalConfigurationManager_5_Time_Should_Throw' {
            $resource = ConvertTo-Dsc -InputObject $config
            {Invoke-Dsc -Resource $resource -Retry 5 -Delay 1 -WarningAction SilentlyContinue} | Should -Throw
        }
    }
}
