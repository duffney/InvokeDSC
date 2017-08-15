$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

Describe "Get-ModuleFromConfiguration Tests" {

    BeforeAll {
        $multipleModulesNoVersion = @"
{
    "Modules":[
        {
            "ModuleName":"xPSDesiredStateConfiguration"
        },
        {
            "ModuleName":"xWebAdministration"
        }
    ],
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
   "Modules":[
        {
            "ModuleName":"xWebAdministration"
        }
   ],
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
    "Modules":[
        {
            "ModuleName":"xPSDesiredStateConfiguration",
            "ModuleVersion":"6.4.0.0"
        }        
    ],
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
    "Modules":[
        {
            "ModuleName":"xPSDesiredStateConfiguration",
            "ModuleVersion":"6.4.0.0"
        },
        {
            "ModuleName":"xWebAdministration",
            "ModuleVersion":"1.17.0.0"
        },
        {
            "ModuleName":"xWebAdministration",
            "ModuleVersion":"1.17.0.0"
        }        
    ],
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

    New-Item -Path 'testdrive:\multipleModulesNoVersion.json' -Value $multipleModulesNoVersion -ItemType File
    New-Item -Path 'testdrive:\singleModuleNoVersion.json' -Value $singleModuleNoVersion -ItemType File
    New-Item -Path 'testdrive:\singleModuleVersion.json' -Value $singleModuleVersion -ItemType File
    New-Item -Path 'testdrive:\multipleModulesVersion.json' -Value $multipleModulesVersion -ItemType File
}

    it 'command should exists' {
        Get-Command -Name Get-ModuleFromConfiguration | should not BeNullOrEmpty
    }

    Context 'Single Module' {
        
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\singleModuleNoVersion.json'

        it "Count Should Be 1" {
            $result.ModuleName.count | should be 1
        }

        it "Should Match xWebAdministration" {
            $result.ModuleName | should be 'xWebAdministration'
        }
    }

    Context 'Multipule Modules' {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\multipleModulesNoVersion.json'

        it 'Count Should Be 2' {
            $result.ModuleName.count | should be 2
        }

        it 'Should match xWebAdministration|xPSDesiredStateConfiguration' {
            $result.ModuleName | should match 'xWebAdministration|xPSDesiredStateConfiguration'
        }
    }

    Context 'Single Module with ModuleVersion' {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\singleModuleVersion.json'

        it 'ModuleVersion should be 6.4.0.0' {
            $result.ModuleVersion | should be '6.4.0.0'
        }

        it 'PSobject Properties should match ModuleName|ModuleVersion' {
            ($result.psobject.properties.name) | should match 'ModuleName|ModuleVersion'
        }
    }

    Context 'Multiple Modules with ModuleVersion' {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\multipleModulesVersion.json'

        it 'ModuleVersion count should be 2' {
            $result.ModuleVersion.count | should be 2
        }

        it 'xPSDesiredStateConfiguration ModuleVersion should Match 6.4.0.0' {
            ($result | Where-Object ModuleName -EQ 'xPSDesiredStateConfiguration').ModuleVersion | should be '6.4.0.0'
        }

        it 'xWebAdministration ModuleVersion should Match 1.17.0.0' {
            ($result | Where-Object ModuleName -EQ 'xWebAdministration').ModuleVersion | should be '1.17.0.0'
        }        
    }

    #Input objects
}