function Install-ModuleFromConfiguration {
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
        [Parameter(Mandatory = $true, ParameterSetName = 'Path', Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $true, ParameterSetName = 'InputObject', Position = 1)]
        [object]$InputObject,
        [Parameter(Mandatory=$false)]
        [string]$Repository = 'PSGallery'            
    )
    
    begin 
    {
        if ($PSBoundParameters.ContainsKey('Path')) 
        {
            $modules = Get-ModuleFromConfiguration -Path $Path
            
            if (!($modules))
            {
                Write-Verbose -Message 'No Modules declared in configuration...'
                return
            }
        }
        else 
        {
            $modules = Get-ModuleFromConfiguration -InputObject $InputObject
            
            if (!($modules))
            {
                Write-Verbose -Message 'No Modules declared in configuration...'
                return
            }
        }
    }
    
    process 
    {
        foreach ($module in $modules)
        {
            if ($null -eq $module.value)
            {
                if (!(Get-Module -Name $module.Name -ListAvailable)){
                    Write-Verbose -Message "[$($module.Name)]  not found"
                    Write-Verbose -Message "Installing [$($module.Name)]"
                    Find-Module $module.Name -Repository $Repository | Sort-Object Version -Descending | Install-Module -Confirm:$false
                }
                else
                {
                    Write-Verbose -Message "Module [$($module.Name)] already exists"
                }
            }
            else
            {
                if (!(Get-Module -FullyQualifiedName @{ModuleName=$module.Name;RequiredVersion=$module.Value} -ListAvailable)) 
                {
                    Write-Verbose -Message "[$($module.Name)] not found with version [$($module.Value)]"
                    Write-Verbose -Message "Installing [$($module.Value)] of [$($module.Name)]"
                    Install-Module -Name $module.Name -RequiredVersion $module.value -Repository $Repository -Confirm:$false
                }
                else
                {
                    Write-Verbose -Message "Module [$($module.Name)] version [$($module.Value)] already exists"
                }                    
            }
        }
    }
    
    end {
    }
}