function Invoke-DSCParse {
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    begin {
        $data = Get-Content -Path $path -Raw | ConvertFrom-Json
    }
    
    process {
        
        foreach ($dscResource in $data.DSCResourcesToExecute) {

            $resource = Get-DscResource -Name $dscResource.dscResourceName

            $module = $resource.ModuleName

            if ($dscResource.dscResourceName -eq 'file') {
                $module = 'PSDesiredStateConfiguration'
            }
            
            $Config = @{
            Name = ($dscResource.dscResourceName)
                Property = @{
                }
            }

            $dsckeys = ($dscResource.psobject.Properties -notmatch 'dscResourceName')

            foreach ($dscKey in $dscKeys) {
                $key = $dscKey
                $prop = $resource.Properties | Where-Object {$_.Name -eq $key.Name}

                switch ($prop.PropertyType) {
                    '[string]'
                     {
                        [string]$KeyValue = $key.value
                        $config.Property.Add($key.Name,$KeyValue)
                     }
                    '[string[]]'
                     {
                        #KeyValue is an array of strings
                        [String]$TempKeyValue = $key.value
                        [String[]]$KeyValue = $TempKeyValue.Split(",").Trim()

                        $config.Property.Add($key.Name,$KeyValue)
                     }
                }
            }

            try {
                Write-Verbose -Message "Running [Test] method on [$($dscResource.name)]"
                $testResults = Invoke-DscResource @Config -Method Test -ModuleName $module -ErrorAction SilentlyContinue -ErrorVariable TestError
                
                if ($TestError) {
                    Write-Error ($TestError[0].Exception.Message)
                }

                elseif (($testResults.InDesiredState) -eq $false) {
                    Invoke-DscResource @Config -Method Set -ModuleName $module -ErrorAction SilentlyContinue -ErrorVariable SetError
                }

                if ($SetError) {
                    Write-Error "Failed to invoke [$($dscresource.resourceName)] ($SetError[0].Exception.Message)"
                }
            }
            catch [System.Exception] {
                # Exception is stored in the automatic variable _
                
            }        
        }        
    }
    
    end {
    }
}