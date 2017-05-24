. "$PSScriptRoot\..\..\InvokeDSC\Public\ConvertTo-DSC.ps1"

Describe "Function Loaded" {

    it "command exists" {
        (Get-Command -Name ConvertTo-DSC) | should not beNullorEmpty
    }

    BeforeAll {
        $newFileJson = @"
{
   "DSCResourcesToExecute":[
      {
          "resourceName":"NewFile",
          "dscResourceName":"File",
          "destinationPath":"c:\\archtype\\file.txt",
          "type":"File",
          "contents":"Test",
          "attributes":["hidden","archive"],
          "ensure":"Present",
          "force":true
      }
   ]
}
"@

    $xWebSiteJson = @"
{
   "Modules":[
        "xWebAdministration"
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

    $xWebApplication = @"
{
   "Modules":[
        "xWebAdministration"
   ],      
   "DSCResourcesToExecute":[
      {
         "resourceName":"archtype",
         "dscResourceName":"File",
         "DestinationPath":"c:\\archtype\\DevOps",
         "Type":"Directory",
         "ensure":"Present"
      },
      {
          "resourceName":"DevOpsApp",
          "dscResourceName":"xWebApplication",
          "name":"DevOps",
          "PhysicalPath":"C:\\archtype\\DevOps",
          "WebAppPool":"DefaultAppPool",
          "WebSite":"Default Web Site",
          "PreloadEnabled":true,
          "EnabledProtocols":["http"],
          "Ensure":"Present",
          "AuthenticationInfo":[
                {
                    "CimType":"MSFT_xWebApplicationAuthenticationInformation",
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

    New-Item -Path 'testdrive:\newfile.json' -Value $newFileJson -ItemType File
    New-Item -Path 'testdrive:\xWebSite.json' -Value $xWebSiteJson -ItemType File
    New-Item -Path 'testdrive:\xWebApplication.json' -Value $xWebApplication -ItemType File
}    

    Context "Parameter Tests" {
        
        $result = ConvertTo-DSC -InputObject (Get-Content -Path "testdrive:\xWebSite.json")

        It "InputObject results should not BeNullorEmpty" {
            $result | Should not beNullorEmpty
        }

        $result = ConvertTo-DSC -Path "testdrive:\xWebSite.json"

        It "Path results should not BeNullorEmpty" {
            $result | should not be beNullorEmpty
        }
    }

    Context "File Resource Test" {

        $result = ConvertTo-DSC -Path "testdrive:\newfile.json"

        it "result should not be null" {
            $result | should not beNullorEmpty
        }

        it "resourceName should be NewFile" {
            $result.resourceName | should be 'NewFile'
        }

        it "dscResourceName should be File" {
            $result.dscResourceName | should be 'File'
        }

        it "ModuleName should be PSDesiredStateConfiguration" {
            $result.ModuleName | should be 'PSDesiredStateConfiguration'
        }

        it "destinationPath should be c:\archtype\Service\file.txt" {
            $result.Property.destinationPath | should be 'c:\archtype\file.txt'
        }

        it "force should be true" {
            $result.Property.force | should be $true
        }

        it "force should be bool" {
            $result.Property.force | should BeofType bool
        }

        it "attributes should be array" {
            $result.Property.attributes -is [System.Array] | should be $true
        }

        it "attributes should match hidden,archive" {
            $result.Property.attributes | should match 'Hidden|Archive'
        }
    }

    Context "xWebApplication Test" {

        $result = ConvertTo-DSC -Path 'testdrive:\xWebApplication.json'

        it "AuthenticationInfo should be type of ciminstnace" {
            $result[1].Property.AuthenticationInfo.GetType().Name | should be 'CimInstance'
        }

        it "Anonymous should BeofType bool" {
            $result[1].Property.AuthenticationInfo.Anonymous | should BeofType bool
        }
    }

    Context "xWebSite" {
        $result = ConvertTo-DSC -Path 'testdrive:\xWebSite.json'

        it "bindinginfo should be CimInstance[]" {
            $result.Property.bindinginfo.GetType().Name | should be 'CimInstance[]'
        }

        it "bindinginfo port should be UInt32" {
            $result.Property.bindinginfo[0].port | should BeofType 'Int32'
        }

        it "bindinginfo protocol should match http|https|net.tcp" {
            $result.Property.bindinginfo[0].protocol | should match 'https?|net.tcp'
        }

        it "bindinginfo protocol should be String" {
            $result.Property.bindinginfo[0].protocol | should BeofType 'string'
        }
    }
}