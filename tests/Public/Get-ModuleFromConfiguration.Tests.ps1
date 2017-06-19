$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"

Describe "Get-ModuleFromConfiguration Tests" {

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

    $CntfsAccessControl = @"
{
    "Modules":[
       "cNtfsAccessControl" 
    ],
   "DSCResourcesToExecute":{
      "LogPermissions":{
         "dscResourceName":"cNtfsPermissionEntry",
         "Path":"c:\\archtype\\Logs",
         "Principal":"IIS APPPOOL\\DevOps",
         "AccessControlInformation":[
            {
               "CimType":"cNtfsAccessControlInformation",
               "Properties":{
                  "AccessControlType":"Allow",
                  "FileSystemRights":["Modify"],
                  "Inheritance":"ThisFolderSubfoldersAndFiles",
                  "NoPropagateInherit":false
               }
            }
         ],
         "ensure":"Present"
      }
   }
}       
"@

    New-Item -Path 'testdrive:\newfile.json' -Value $newFileJson -ItemType File
    New-Item -Path 'testdrive:\xWebSite.json' -Value $xWebSiteJson -ItemType File
    New-Item -Path 'testdrive:\xWebApplication.json' -Value $xWebApplication -ItemType File
    New-Item -Path 'testdrive:\cNtfsAccessControl.json' -Value $cNtfsAccessControl -ItemType File
}

    it "command should exists" {
        Get-Command -Name Get-ModuleFromConfiguration | should not BeNullOrEmpty
    }

    Context "Single Configuration" {
        
        $result = Get-ModuleFromConfiguration -Path 'testdrive:\xWebSite.json'

        it "Count Should Be 1" {
            $result.count | should be 1
        }

        it "Should Match xWebAdministration" {
            $result | should be 'xWebAdministration'
        }
    }

    Context "Multiple Configurations" {
        $result = Get-ModuleFromConfiguration -Path 'testdrive:' -Recurse

        it "Count Should BeGreaterThan 2" {
            $result.count | should BeGreaterThan 1
        }

        it "Should match xWebAdministration|cNtfsAccessControl" {
            $result | should match ([regex]::('xWebAdministration|cNtfsAccessControl'))
        }
    }
}