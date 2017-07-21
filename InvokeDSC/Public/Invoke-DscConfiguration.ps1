function Invoke-DscConfiguration {
<#
.SYNOPSIS
    Invokes a specified configuration file with Desired State Configuration
.DESCRIPTION
    Prases the specified configuration file and extracts out unique Dsc resource
    modules required and attempts to download them. Once the modules are obtained it converts
    the configuration document to a PowerShell object which is passed to Invoke-Dsc to
    invoke the resources.
.PARAMETER Path
    Specifies the path to a .json file.
.PARAMETER InputObject
    Specifies an InputObject containing json synatx
.EXAMPLE
    Invoke-DscConfiguration -Path 'c:\config\NewFile.json'
.EXAMPLE
    Invoke-DscConfiguration -Path 'c:\config\NewFile.json' -Repository PSGallery
.EXAMPLE
    Invoke-DscConfiguration -InputObject $json-object 
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Path', Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $true, ParameterSetName = 'InputObject', Position = 1)]
        [object[]]$InputObject,
        [Parameter(Mandatory=$false)]
        [string]$Repository = 'PSGallery'
    )
    
    begin 
    {
        Write-Verbose -Message "Getting required modules"
        if ($PSBoundParameters.ContainsKey('Path')) {
            $modules = Get-ModuleFromConfiguration -Path $Path
        }
        else {
            $modules = Get-ModuleFromConfiguration -InputObject $InputObject
        }
        
        

        foreach ($module in $modules) 
        {
            Write-Verbose -Message "Verifying [$module] exists"
            
            if (!(Get-Module -name $module -ListAvailable))
            {
                Write-Verbose -Message "[$module]  not found"
                Write-Verbose -Message "Installing [$module]"
                Find-Module $module -Repository $Repository | Sort-Object Version -Descending | Install-Module -Confirm:$false                
            }
            else
            {
                Write-Verbose -Message "Module [$module] already exists"
            }


        }

        Write-Verbose -Message "Converting configuration to Dsc Object"
        if ($PSBoundParameters.ContainsKey('Path')) {
            $resourceObject = ConvertTo-DSC -Path $Path
        }
        else {
            $resourceObject = ConvertTo-DSC -InputObject $InputObject
        }
        
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