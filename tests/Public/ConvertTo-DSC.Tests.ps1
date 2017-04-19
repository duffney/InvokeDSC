. "$PSScriptRoot\..\..\InvokeDSC\Public\ConvertTo-DSC.ps1"

Describe "Function Loaded" {

    it "command exists" {
        (Get-Command -Name ConvertTo-DSC) | should not beNullorEmpty
    }

    Context "File Resource Test" {

        $result = ConvertTo-DSC -Path $PSScriptRoot\..\..\examples\NewFile.json

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

        it "destinationPath should be c:\Paylocity\Service\file.txt" {
            $result.Property.destinationPath | should be 'c:\Paylocity\Service\file.txt'
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

        $result = ConvertTo-DSC -Path $PSScriptRoot\..\..\examples\xWebApplication.json

        it "AuthenticationInfo should be type of ciminstnace" {
            $result[1].Property.AuthenticationInfo.GetType().Name | should be 'CimInstance'
        }

        it "Anonymous should BeofType bool" {
            $result[1].Property.AuthenticationInfo.Anonymous | should BeofType bool
        }
    }

    Context "xWebSite" {
        $result = ConvertTo-DSC -Path $PSScriptRoot\..\..\examples\xWebSite.json

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