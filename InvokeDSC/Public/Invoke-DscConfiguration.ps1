function Invoke-DscConfiguration {
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
        [Parameter(Mandatory=$false)]
        [string]$Repository = 'PSGallery'
    )
    
    begin 
    {
        Write-Verbose -Message "Getting required modules"
        $modules = Get-ModuleFromConfiguration -Path $Path

        foreach ($module in $modules) 
        {
            Write-Verbose -Message "Installing [$module]"
            Install-Module -Name $module -Repository $Repository -Confirm:$false
        }

        Write-Verbose -Message "Converting configuration to Dsc Object"
        $resourceObject = ConvertTo-DSC -Path $Path
    }
    
    process
    {
        Write-Verbose -Message "Invoking Dsc resources"
        Invoke-DSC -Resources $resourceObject
    }
    
    end
    {
        
    }
}