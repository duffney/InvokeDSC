$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

Describe "Get-ModuleFromConfiguration Tests" {

    BeforeAll {
        $multipleModulesNoVersion = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":null,
        "xWebAdministration":null
    },
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

    $singleModuleNoVersion = @"
{
   "Modules":{
        "xWebAdministration":null
    },
   "DSCResourcesToExecute":[
      {
         "resourceName":"archtypeSite",
         "dscResourceName":"xWebsite",
         "name":"archtype",
         "State":"Started",
         "physicalPath":"c:\\archtype",
         "ensure":"Present",
         "bindingInfo":[
            {
               "CimType":"MSFT_xWebBindingInformation",
               "Properties":{
                     "protocol":"http",
                     "port":8081,
                     "ipaddress":"127.0.0.1"
                  }
            },
            {
               "CimType":"MSFT_xWebBindingInformation",
               "Properties":{
                     "protocol":"http",
                     "port":8080,
                     "ipaddress":"127.0.0.1"
                  }
            }
         ],
          "AuthenticationInfo":[
                {
                    "CimType":"MSFT_xWebAuthenticationInformation",
                    "Properties":{
                        "Anonymous":true,
                        "Basic":true
                    }
                }
           ]
      }
   ]
}
"@

    $singleModuleVersion = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":"6.4.0.0"        
    },
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

    $multipleModulesVersion = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":"6.4.0.0",
        "xWebAdministration":"1.17.0.0"
    },
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

    $arrayModules = @"
{
    "Modules":[
        "xPSDesiredStateConfiguration",
        "xWebAdministration"
    ],
    "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
    }
}
"@

    New-Item -Path 'testdrive:\multipleModulesNoVersion.json' -Value $multipleModulesNoVersion -ItemType File
    New-Item -Path 'testdrive:\singleModuleNoVersion.json' -Value $singleModuleNoVersion -ItemType File
    New-Item -Path 'testdrive:\singleModuleVersion.json' -Value $singleModuleVersion -ItemType File
    New-Item -Path 'testdrive:\multipleModulesVersion.json' -Value $multipleModulesVersion -ItemType File
    New-Item -Path 'testdrive:\noModules.json' -Value $noModules -ItemType File
    New-Item -Path 'testdrive:\arrayModules.json' -Value $arrayModules -ItemType File
}

    it 'command should exists' {
        Get-Command -Name Get-ModuleFromConfiguration | should not BeNullOrEmpty
    }

    Context 'Single Module' {
        
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\singleModuleNoVersion.json'

        it "Count Should Be 1" {
            $result.count | should be 1
        }

        it "Should Match xWebAdministration" {
            $result.Name | should be 'xWebAdministration'
        }
    }

    Context 'Multipule Modules' {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\multipleModulesNoVersion.json'

        it 'Count Should Be 2' {
            $result.count | should be 2
        }

        it 'Should match xWebAdministration|xPSDesiredStateConfiguration' {
            $result.Name | should match 'xWebAdministration|xPSDesiredStateConfiguration'
        }
    }

    Context 'Single Module with ModuleVersion' {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\singleModuleVersion.json'

        it 'ModuleVersion should be 6.4.0.0' {
            $result.Value | should be '6.4.0.0'
        }

        it 'Name should match xPSDesiredStateConfiguration' {
            ($result.name) | should match 'xPSDesiredStateConfiguration'
        }
    }

    Context 'Multiple Modules with ModuleVersion' {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\multipleModulesVersion.json'

        it 'ModuleVersion count should be 2' {
            $result.count | should be 2
        }

        it 'xPSDesiredStateConfiguration ModuleVersion should Match 6.4.0.0' {
            ($result | Where-Object Name -EQ 'xPSdesiredStateConfiguration').value | should be '6.4.0.0'
        }

        it 'xWebAdministration ModuleVersion should Match 1.17.0.0' {
            ($result | Where-Object Name -EQ 'xWebAdministration').value | should be '1.17.0.0'
        }        
    }

    Context 'No Modules' {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\noModules.json'

        it 'Count should be 0' {
            $result.count | should be 0
        }
    }

    Context 'Array Modules' {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\arrayModules.json'

        it 'Name count should be 2' {
            $result.Name.count | should be 2
        }

        it '$result[0] Name should match xPSDesiredStateConfiguration' {
            $result[0].Name | should match 'xPSDesiredStateConfiguration'
        }

        it '$result[1] Name should match xWebAdministration' {
            $result[1].Name | should match 'xWebAdministration'
        }

        it '$result[0] Value should be $null' {
            $result[0].Value | should be $null
        }

        it '$result[1] Value should be $null' {
            $result[1].Value | should be $null
        }
    }

    #Input objects
}