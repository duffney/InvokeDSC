$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"
. "$here\Get-ModuleFromConfiguration.ps1"

Describe "Install-ModuleFromConfiguration Specified Module Version" {

    BeforeAll {
    $singleModuleVersion = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":"6.0.0.0"     
    },
   "DSCResourcesToExecute":{
   }
}
"@

    New-Item -Path 'testdrive:\singleModuleVersion.json' -Value $singleModuleVersion -ItemType File
    
    if (Get-Module -Name xPSDesiredStateConfiguration -ListAvailable){
        (Get-Module -Name xPSDesiredStateConfiguration -ListAvailable).modulebase | % {Remove-Item -Path $_ -Recurse -Force}
    }

    Set-PackageSource -Name PSGallery -Trusted -Force
}

    It 'Install-ModuleFromConfiguration cmdlet exists' {
        Get-Command -Name Install-ModuleFromConfiguration | should not BeNullOrEmpty
    }
    
    Context 'Specified Module Version' {

        Install-ModuleFromConfiguration -Path 'testdrive:\singleModuleVersion.json'
        
        It 'Module should exist' {
            (Get-Module -Name xPSDesiredStateConfiguration -ListAvailable) | Should not BeNullOrEmpty
        }

        It 'Module Version should match' {
            (Get-Module -Name xPSDesiredStateConfiguration -ListAvailable).Version | should match '6.0.0.0'

        }

    }
}

Describe 'Install-ModuleFromConfiguration No Specified Module Version' {
    BeforeAll {
        $NoModuleVersion = 
@"
    {
        "Modules":{
            "xPSDesiredStateConfiguration":null
        },
       "DSCResourcesToExecute":{
       }
    }
"@
    
        New-Item -Path 'testdrive:\NoModuleVersion.json' -Value $NoModuleVersion -ItemType File
        
        if (Get-Module -Name xPSDesiredStateConfiguration -ListAvailable){
            (Get-Module -Name xPSDesiredStateConfiguration -ListAvailable).modulebase | % {Remove-Item -Path $_ -Recurse -Force}
        }
    
        Set-PackageSource -Name PSGallery -Trusted -Force
    }

    Context 'No Specified Module Version' {
        
        Install-ModuleFromConfiguration -Path 'testdrive:\NoModuleVersion.json'
        
        It 'Module should exist' {
            (Get-Module -Name xPSDesiredStateConfiguration -ListAvailable) | Should not BeNullOrEmpty
        }
    }    
}

Describe 'No Modules' {
    BeforeAll {
        $noModules = @"
        {
            "DSCResourcesToExecute":{
                "NewFile":{
                    "dscResourceName":"File",
                    "destinationPath":"c:\\archtype\\file.txt",
                    "type":"File",
                    "contents":"Test",
                    "attributes":["hidden","archive"],
                    "ensure":"Present",
                    "force":true
                }
            }
        }
"@

        New-Item -Path 'testdrive:\noModules.json' -Value $noModules -ItemType File
    }

    it 'Find-Module should be called 0 times' {
        mock -CommandName Find-Module -MockWith {}
        $null = Install-ModuleFromConfiguration -Path 'testdrive:\noModules.json'
        Assert-MockCalled -CommandName Find-Module -Times 0
    }
}

Describe "ReturnShouldNotBeCalled" {
    Context 'Will it work?' {
$config = @"
{
    "Modules":{
        "cChoco":null,
        "PackageManagement":"1.1.6.0",
        "PackageManagementProviderResource":null
    },
"DSCResourcesToExecute":{
        "RegisterPowerShellFeed":{
            "dscResourceName":"PackageManagementSource",
            "name":"Internal",
            "SourceUri":"https://artifact.paylocity.com/artifactory/api/nuget/powershell",
            "providerName":"PowerShellGet",
            "InstallationPolicy":"Trusted",
            "ensure":"Present"
        },
        "chocoSource":{
        "dscResourceName":"cChocoSource",
            "Name":"PCTYchoco",
            "Priority":0,
            "source":"https://artifact.paylocity.com/artifactory/api/nuget/chocolatey-local"
        }     
    }
}
"@
Mock Write-Verbose {} -Verifiable -ParameterFilter { $Message -eq 'No Modules declared in configuration...'}
        It 'should not call return' {
           {Install-ModuleFromConfiguration -InputObject $config} | should not throw
        }

        It 'mocking write-verbose' {
            Assert-MockCalled Write-Verbose -Times 0 -Exactly
        }
    } 
}