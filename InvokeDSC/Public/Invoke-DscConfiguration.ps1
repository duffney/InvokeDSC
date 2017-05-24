function Invoke-DscConfiguration {
<#
.SYNOPSIS
    Invokes a specified configuration file with Desired State Configuration
.DESCRIPTION
    Prases the specified configuration file and extracts out unique Dsc resource
    modules required and attempts to download them. Once the modules are obtained it converts
    the configuration document to a PowerShell object which is passed to Invoke-Dsc to
    invoke the resources.
.EXAMPLE
    Invoke-DscConfiguration -Path 'c:\config\NewFile.json'
.EXAMPLE
    Invoke-DscConfiguration -Path 'c:\config\NewFile.json' -Repository PSGallery
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
            Write-Verbose -Message "Verifying [$module] exists"
            
            if (!(Get-Module -name $module -ListAvailable))
            {
                Write-Verbose -Message "[$module]  not found"
                Write-Verbose -Message "Installing [$module]"
                Install-Module -Name $module -Repository $Repository -Confirm:$false                
            }
            else
            {
                Write-Verbose -Message "Module [$module] already exists"
            }


        }

        Write-Verbose -Message "Converting configuration to Dsc Object"
        $resourceObject = ConvertTo-DSC -Path $Path
    }
    
    process
    {
        Write-Verbose -Message "Invoking Dsc resources"
        Invoke-DSC -Resource $resourceObject
    }
    
    end
    {
        
    }
}