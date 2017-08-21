$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

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
            (Get-Module -Name xPSDesiredStateConfiguration -ListAvailable | Where-Object version -Match '6.0.0.0') | should not BeNullOrEmpty

        }

    }
}

Describe 'Install-ModuleFromConfiguration No Specified Module Version' {
    BeforeAll {
        $singleModuleVersion = 
@"
    {
        "Modules":{
            "xPSDesiredStateConfiguration":null
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

    Context 'No Specified Module Version' {
        
        Install-ModuleFromConfiguration -Path 'testdrive:\singleModuleVersion.json'
        
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
        $result = Install-ModuleFromConfiguration -Path 'testdrive:\noModules.json'
        Assert-MockCalled -CommandName Find-Module -Times 0
    }
}