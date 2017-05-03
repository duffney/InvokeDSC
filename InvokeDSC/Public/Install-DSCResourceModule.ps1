function Install-DSCResourceModule {
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
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string[]]$Name,
        [Parameter(Mandatory=$false)]
        [string]$Version,
        [Parameter(Mandatory=$false)]
        [string]$Repository
    )
    
    begin {
       
       $installParams = @{
           'Name' = $Name
       }

       if ($PSBoundParameters.ContainsKey('Repository')) {
           $installParams.Add('Repository',$Repository)
       }

       if ($PSBoundParameters.ContainsKey('Version')) {
           $installParams.Add('RequiredVersion',$Version)
       }

    }
    
    process {
        
        foreach ($moduleName in $Name) {

            if ($PSBoundParameters.ContainsKey('Version'))
            {
                try 
                {
                    $module = Get-Module -Name $moduleName -ListAvailable

                    if ($module.Version -eq $Version) 
                    {
                        Write-Verbose -Message "Module [$Name] found Version matches [$Version]"
                    }
                    else 
                    {
                        Write-Warning -Message "Module [$Name] version does not match"
                        Write-Warning -Message "Expecting [$Version] was [$($module.Version)]"
                        Write-Verbose -Message "Removing [$Name] version [$($module.Version)"
                        #Run Remove-Module helper
                        Write-Verbose -Message "Installing [$Name] version [$Version]"
                        Install-Module @installParams
                    }
                }
                catch
                {
                    Write-Verbose -Message "Module [$Name] not found"
                    Install-Module @installParams
                }

            }
            else
            {
                if (!(Get-Module -Name $moduleName -ListAvailable)) 
                {
                    Write-Verbose -Message "Installing [$Name]"
                    Install-Module @installParams
                }
                else
                {
                    Write-Verbose -Message "Module [$Name] already exists"
                }
            }
        } #end foreach
        } #end Process
    
    end {
    }
}

#Install-DSCResourceModule -Name xnetworking -Version '3.2.0.0' -Verbose