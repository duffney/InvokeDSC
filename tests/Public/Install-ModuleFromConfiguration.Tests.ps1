$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

Describe 'Install-ModuleFromConfiguration' {

    BeforeAll {
        Function Get-ModuleFromConfiguration  {
        }
        Function Get-Module {
            param()
            throw 'Fake Get-Module cmdlet'
        }

        Function Find-Module {
            param()
            throw 'Fake Find-Module cmdlet'
        }

        Function Install-Module {
            param()
            throw 'Fake Install-Module cmdlet'
        }
    }

    Context 'NoModulesNeeded_Should_WriteVerboseMessage' {

        Mock Write-Verbose {} -Verifiable -ParameterFilter { $Message -eq 'No Modules declared in configuration...'}

        $NoModules = @"
{
    "DSCResourcesToExecute":{
    }
}
"@


        It 'mocking write-verbose' {
            Install-ModuleFromConfiguration -InputObject $noModules
            Assert-MockCalled Write-Verbose -Times 1 -Exactly
        }
    }

    Context 'NoModuleVersion_ModuleExists' {

        Mock Get-ModuleFromConfiguration {
            [PSCustomObject]@{
                Name = 'xPSDesiredStateConfiguration'
                Value = $null
            }
        }

        Mock Get-Module {
            [PSCustomObject]@{
                ModuleType = 'Script'
                Version = '7.0.0.0'
                Name = 'xPSDesiredStateConfiguration'
            }
        } -Verifiable

        Mock Find-Module {
            [PSCustomObject]@{
                Version = [version]'7.0.0.0'
                Name = 'xPSDesiredStateConfiguration'
                Repository = 'PSGallery'
            }
        }

        Mock Install-Module {

        }

        $singleModuleVersion = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":null
    },
    "DSCResourcesToExecute":{
    }
}
"@

        It 'Install-Module_Should_Not_Be_Called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Install-Module -Times 0 -Exactly
        }
        It 'Find-Module_Should_Not_Be_called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Find-Module -Times 0 -Exactly
        }
        It 'Get-Module_Mock_Verifiable' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-VerifiableMock
        }

    }

    Context 'ModuleVersion_ModuleExists' {

        Mock Get-ModuleFromConfiguration {
            [PSCustomObject]@{
                Name = 'xPSDesiredStateConfiguration'
                Value = '7.0.0.0'
            }
        }

        Mock Get-Module {
            [PSCustomObject]@{
                ModuleType = 'Script'
                Version = '7.0.0.0'
                Name = 'xPSDesiredStateConfiguration'
            }
        } -Verifiable

        Mock Find-Module {
            [PSCustomObject]@{
                Version = [version]'7.0.0.0'
                Name = 'xPSDesiredStateConfiguration'
                Repository = 'PSGallery'
            }
        }

        Mock Install-Module {

        }

        $singleModuleVersion = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":"6.0.0.0"
    },
    "DSCResourcesToExecute":{
    }
}
"@

        It 'Install-Module_Should_Not_Be_Called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Install-Module -Times 0 -Exactly
        }
        It 'Find-Module_Should_Not_Be_called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Find-Module -Times 0 -Exactly
        }
        It 'Get-Module_Mock_Verifiable' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-VerifiableMock
        }
    }
   Context 'ModuleVersion_RequiredModuleDoesNotExist' {

        Mock Get-ModuleFromConfiguration {
            [PSCustomObject]@{
                Name = 'xPSDesiredStateConfiguration'
                Value = '6.0.0.0'
            }
        }

        Mock Get-Module {
        } -Verifiable

        Mock Find-Module {
            [PSCustomObject]@{
                Version = [version]'7.0.0.0'
                Name = 'xPSDesiredStateConfiguration'
                Repository = 'PSGallery'
            }
        }

        Mock Install-Module {

        }

        $singleModuleVersion = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":"6.0.0.0"
    },
    "DSCResourcesToExecute":{
    }
}
"@

        It 'Install-Module_Should_Not_Be_Called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Install-Module -Times 1 -Exactly
        }
        It 'Find-Module_Should_Not_Be_called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Find-Module -Times 0 -Exactly
        }
        It 'Get-Module_Mock_Verifiable' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-VerifiableMock
        }
    }

    Context 'ModuleVersion_ModuleNotExists' {

            Mock Get-ModuleFromConfiguration {
                [PSCustomObject]@{
                    Name = 'xPSDesiredStateConfiguration'
                    Value = $null
                }
            }

            Mock Get-Module {} -Verifiable

            Mock Find-Module {
                [PSCustomObject]@{
                    Version = [version]'7.0.0.0'
                    Name = 'xPSDesiredStateConfiguration'
                    Repository = 'PSGallery'
                }
            }

            Mock Install-Module {

            }

            $singleModuleVersion = @"
{
"Modules":{
    "xPSDesiredStateConfiguration":null
},
"DSCResourcesToExecute":{
}
}
"@

        It 'Install-Module_Should_Not_Be_Called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Install-Module -Times 1 -Exactly
        }
        It 'Find-Module_Should_Not_Be_called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Find-Module -Times 2 -Exactly
        }
        It 'Get-Module_Mock_Verifiable' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-VerifiableMock
        }
    }

    Context 'ModuleVersion_ModuleNotExists' {

        Mock Get-ModuleFromConfiguration {
            [PSCustomObject]@{
                Name = 'xPSDesiredStateConfiguration'
                Value = $null
            }
        }

        Mock Get-Module {} -Verifiable

        Mock Find-Module {
            [PSCustomObject]@{
                Version = [version]'7.0.0.0'
                Name = 'xPSDesiredStateConfiguration'
                Repository = 'PSGallery'
            }
        }

        Mock Install-Module {

        }

        $singleModuleVersion = @"
    {
"Modules":{
    "xPSDesiredStateConfiguration":null
},
"DSCResourcesToExecute":{
}
}
"@

        It 'Install-Module_Should_Not_Be_Called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-MockCalled -CommandName Install-Module -Times 1 -Exactly
        }
        It 'Find-Module_Should_Not_Be_called' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            #Called twice because of stubbing
            Assert-MockCalled -CommandName Find-Module -Times 2 -Exactly
        }
        It 'Get-Module_Mock_Verifiable' {
            Install-ModuleFromConfiguration -InputObject $singleModuleVersion
            Assert-VerifiableMock
        }
    }
}
