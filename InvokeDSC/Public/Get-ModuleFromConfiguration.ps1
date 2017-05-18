function Get-ModuleFromConfiguration {
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
        [string]$Path,
        [switch]$Recurse

    )
    
    begin {

        if (!($Recurse))
        {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
        }
        else
        {
            $data = Get-ChildItem -Path $Path -Recurse -File | Get-Content -Raw  | ConvertFrom-Json
        }
    }
    
    process {
        
        foreach ($module in $data.Modules) 
        {
            [string[]]$modules += $module
        }
    }
    
    end {
        $modules | Select-Object -Unique
    }
}