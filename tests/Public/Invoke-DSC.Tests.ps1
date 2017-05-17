$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$here = $here -replace 'tests', 'InvokeDSC'

. "$here\$sut"
. "$here\ConvertTo-DSC.ps1"

Describe "Function Loaded" {

    BeforeAll {
        $jsonInput = @"
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
        $resource = ConvertTo-DSC -InputObject $jsonInput
    }

    it "command exists" {
        (Get-Command -Name ($sut -replace '\.ps1')) | should not beNullorEmpty
    }

    it "run Invoke-DSC" {
        (Invoke-DSC -Resources $resource) | should not beNullorEmpty
    }

    it "file.txt should exist" {
        (Test-Path 'C:\archtype\file.txt') | should be $true
    }

    it "content should be [test]" {
        (Get-Content 'C:\archtype\file.txt') | should be 'Test'
    }

    it "attributes should be Hidden|Archive" {
        (Get-ItemProperty C:\archtype\Service\file.txt).Attributes | should match ([regex]::('\bHidden\b|\bArchive\b'))
    }

    AfterAll {
        Remove-Item -Path C:\archtype -Recurse -Force
    }
}