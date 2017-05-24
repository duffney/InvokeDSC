function Invoke-DscConfigurationByRoles {
<#
.SYNOPSIS
    Invokes Dsc configurations by matching role names.
.DESCRIPTION
    Scans a specified directory recursivly to locate matching .json configuration documents. Each .json
    configuration document is then converted to a PowerShell object and invoked.
.PARAMETER Path
    Specifies the path where the .json configuration documents are located.
.PARAMETER Role
    Specifies the roles to invoke, role must match specified .json configuration document name.
.PARAMETER Repository
    Defines the PowerShellGet repository to obtain PowerShell modules
.EXAMPLE
    Invoke-DscConfigurationByRoles -Path C:\confienv\ -Role 'common','common.web' -Repository PSGallery -Verbose
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string[]]$Role,
        [Parameter(Mandatory=$false)]
        [string]$Repository = 'PSGallery'
    )
    
    begin 
    {

    }
    
    process 
    {
        foreach ($r in $role)
        {
            Write-Verbose -Message "Getting [$r] configuration path"
            $configPath = (Get-ChildItem -Path $Path -Recurse -File | Where-Object Name -Match ('^'+[regex]::Escape($($r))+'.json$')).FullName

            if ($configPath)
            {
                Write-Verbose -Message "[$r] configuration found [$configPath]"
                Write-Verbose -Message "Invoking Dsc Configuration for [$r]"
                Invoke-DscConfiguration -Path $configPath -Repository $Repository
            }
            else 
            {
                Write-Verbose -Message "Configuration Not Found for [$r]"
            }
        }

    }
    
    end 
    {

    }
}