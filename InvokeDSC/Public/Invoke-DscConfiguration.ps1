function Invoke-DscConfiguration
{
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
.PARAMETER Retry
    Specifies the amount of times to rety when the Local Configuration Manager State is busy.
.PARAMETER Delay
    Specifies the amount of seconds between retries when the Local Configuration Manager State is busy.
.EXAMPLE
    Invoke-DscConfiguration -Path 'c:\config\NewFile.json'
.EXAMPLE
    Invoke-DscConfiguration -Path 'c:\config\NewFile.json' -Repository PSGallery
.EXAMPLE
    Invoke-DscConfiguration -InputObject $json-object
.EXAMPLE
    Invoke-DscConfiguration -InputObject $json-object -Retry 3 -Delay 30
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Path', Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $true, ParameterSetName = 'InputObject', Position = 1)]
        [object[]]$InputObject,
        [Parameter(Mandatory = $false)]
        [string]$Repository = 'PSGallery',
        [int]$Retry = 5,
        [int]$Delay = 60
    )

    begin
    {
        $ProgPref = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        if ($PSBoundParameters.ContainsKey('Path'))
        {
            Install-ModuleFromConfiguration -Path $Path -Repository $Repository
        }
        else
        {
            Install-ModuleFromConfiguration -InputObject $InputObject -Repository $Repository
        }

        Write-Verbose -Message "Converting configuration to Dsc Object"
        if ($PSBoundParameters.ContainsKey('Path'))
        {
            $resourceObject = ConvertTo-DSC -Path $Path
        }
        else
        {
            $resourceObject = ConvertTo-DSC -InputObject $InputObject
        }

    }

    process
    {
        Write-Verbose -Message "Invoking Dsc resources"
        Invoke-DSC -Resource $resourceObject -Retry $Retry -Delay $Delay
    }

    end
    {
        $global:ProgressPreference = $ProgPref
    }
}
