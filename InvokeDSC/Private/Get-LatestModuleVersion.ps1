function Get-LatestModuleVersion {
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
            [string[]]$Name
        )
        
        begin {
        }
        
        process {
            
            foreach ($moduleName in $Name)
            {
                $module = Get-Module -Name $moduleName -ListAvailable

                if ($module.Count -gt 1) {
                    $version = ($module | Sort-Object Version -Descending | Select-Object -First 1).Version
                }

                [string[]]$results += $version.ToString()
            }
        }
        
        end {
            return $results
        }
    }