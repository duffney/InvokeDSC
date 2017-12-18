function Invoke-Dsc
{
    <#
.SYNOPSIS
Invokes Dsc resources

.DESCRIPTION
Passes PSCustomObjects to Invoke-DscResource by invoking the Test method and
if the Test method fails invokes the Set method.
.PARAMETER Resource
Specifies the PSCustomObject to be passed to Invoke-DscResource
.PARAMETER Retry
Specifies the amount of times to rety when the Local Configuration Manager State is busy.
.PARAMETER Delay
Specifies the amount of seconds between retries when the Local Configuration Manager State is busy.
.EXAMPLE
$r = ConvertTo-Dsc -Path 'c:\Config\NewFile.json'
Invoke-Dsc -Resource $r
.EXAMPLE
$r = ConvertTo-Dsc -Path 'c:\Config\NewFile.json'
Invoke-Dsc -Resource $r -Retry 5 -Dealy 60

.NOTES
Wraps around the native Invoke-DscResource cmdlet and invokes them as native Dsc would
by running the test method first and if the test method fails it invokes the set method.
#>
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [object[]]$Resource,
        [int]$Retry = 5,
        [int]$Delay = 60
    )

    Begin
    {
        $ProgPref = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        $retryCount = 0
        if ((Get-DscLocalConfigurationManager).LCMState -eq 'Busy')
        {
            do
            {
                $retryCount ++
                Write-Warning "Local Configuration Manager is in progress and must return before Invoke-DscResource can be invoked. Will retry in [$Delay] seconds...Retry [$retryCount/$Retry]"
                Start-Sleep -Seconds $Delay
                $LCMstate = (Get-DscLocalConfigurationManager).LCMState
                if ($retryCount -eq $Retry)
                {
                    throw "Local Configuration Manager is in progress after [$Retry] retries. Use -Force option if available or cancel the current operation."
                }
            } until ($retryCount -eq $Retry -or $LCMstate -eq 'Idle')
        }
    }
    Process
    {
        foreach ($r in $Resource)
        {

            $splat = @{
                Name        = $r.dscResourceName
                Property    = $r.Property
                ErrorAction = 'SilentlyContinue'
            }

            if ($null -ne $r.ModuleVersion)
            {
                $splat.Add('ModuleName', @{ModuleName = $($r.ModuleName); ModuleVersion = $($r.ModuleVersion)})
            }
            else
            {
                if ($r.ModuleName -eq 'PSDesiredStateConfiguration' -and $r.dscResourceName -eq 'File')
                {
                    $splat.Add('ModuleName', $r.ModuleName)
                }
                else
                {
                    $latestVersion = Get-LatestModuleVersion -Name $r.ModuleName
                    $splat.Add('ModuleName', @{ModuleName = $($r.ModuleName); ModuleVersion = $latestVersion})
                }
            }

            Write-Output "[Start Test] [[$($r.dscResourceName)]$($r.ResourceName)]"
            $testResults = Invoke-DscResource @splat -Method Test -ErrorVariable TestError -Verbose:$false

            if ($PSCmdlet.ShouldProcess("Invoking Set Method"))
            {

                if ($TestError)
                {
                    Write-Error ("Failed to Invoke $($r.resourceName)" + ($TestError[0].Exception.Message))
                }
                elseif (($testResults.InDesiredState) -ne $true)
                {
                    Write-Output "[Start Set] [[$($r.dscResourceName)]$($r.ResourceName)]"
                    Invoke-DscResource @splat -Method Set -ErrorVariable SetError -Verbose:$false
                }

                if ($SetError)
                {
                    Write-Error "Failed to invoke [$($r.resourceName)] ($SetError[0].Exception.Message)"
                }

            }

        }
    }
    End
    {
        $global:ProgressPreference = $ProgPref
    }
}
