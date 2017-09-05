$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"
. "$here\ConvertTo-DSC.ps1"

Describe "Invoke-Dsc Tests" {

    BeforeAll {
        $jsonInput = @"
{
   "DSCResourcesToExecute":{
      "NewFile:": {
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

$moduleVersion = @"
{
   "Modules":{
           "xPSDesiredStateConfiguration":"6.4.0.0"
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
        $resource = ConvertTo-DSC -InputObject $jsonInput
        $moduleVersionResource = ConvertTo-Dsc -InputObject $moduleVersion

        Set-PackageSource -Name PSGallery -Trusted -Force
        Install-Module -Name xPSDesiredStateConfiguration -Repository PSGallery -RequiredVersion '6.4.0.0' -Force -Confirm:$false        
    }

    it "command exists" {
        (Get-Command -Name ($sut -replace '\.ps1')) | should not beNullorEmpty
    }

    it "run Invoke-DSC" {
        (Invoke-DSC -Resource $resource) | should not beNullorEmpty
    }

    it "file.txt should exist" {
        (Test-Path 'C:\archtype\file.txt') | should be $true
    }

    it "content should be [test]" {
        (Get-Content 'C:\archtype\file.txt') | should be 'Test'
    }

    It "DevOps Group should exist" {
        Invoke-DSC -Resource $moduleVersionResource
        (Get-LocalGroup -Name DevOps) | should not beNullorEmpty
    }
    
    #add test for module version not found

    AfterAll {
        Remove-Item -Path C:\archtype -Recurse -Force
        Remove-LocalGroup -Name DevOps
    }
}