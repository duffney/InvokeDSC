function Invoke-Dsc
{
<#
.SYNOPSIS
Invokes Dsc resources

.DESCRIPTION
Passes PSCustomObjects to Invoke-DscResource first by invoking the test method and
if the test method fails invokes the set method.

.PARAMETER Resource
Specifies the PSCustomObject to be passed to Invoke-DscResource

.EXAMPLE
$r = ConvertTo-Dsc -Path 'c:\Config\NewFile.json'
Invoke-Dsc -Resource $r

.NOTES
Wraps around the native Invoke-DscResource cmdlet and invokes them as native Dsc would
by running the test method first and if the test method fails it invokes the set method.
#>    
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [object[]]$Resource
    )

    Begin
    {
    }
    Process
    {
        foreach ($r in $Resource) {
              
                $splat = @{
                    Name = $r.dscResourceName
                    Property = $r.Property
                    #ModuleName = $r.ModuleName
                    ErrorAction = 'SilentlyContinue'
                }

                if ($r.ModuleVersion -ne $null)
                {
                    $splat.Add('ModuleName',@{ModuleName=$($r.ModuleName);ModuleVersion=$($r.ModuleVersion)})
                }
                else
                {
                    if ($r.ModuleName -eq 'PSDesiredStateConfiguration' -and $r.dscResourceName -eq 'File')
                    {
                        $splat.Add('ModuleName',$r.ModuleName)
                    }
                    else
                    {
                        $latestVersion = Get-LatestModuleVersion -Name $r.ModuleName
                        $splat.Add('ModuleName',@{ModuleName=$($r.ModuleName);ModuleVersion=$latestVersion})
                    }
                }
                
                Write-Output "[Start Test] [[$($r.dscResourceName)]$($r.ResourceName)]"
                $testResults = Invoke-DscResource @splat -Method Test -ErrorVariable TestError -Verbose:$false

                if ($TestError) {
                    Write-Error ("Failed to Invoke $($r.resourceName)" + ($TestError[0].Exception.Message))
                }

                elseif (($testResults.InDesiredState) -ne $true) {
                    Write-Output "[Start Set] [[$($r.dscResourceName)]$($r.ResourceName)]"
                    Invoke-DscResource @splat -Method Set -ErrorVariable SetError -Verbose:$false
                }

                if ($SetError) {
                    Write-Error "Failed to invoke [$($r.resourceName)] ($SetError[0].Exception.Message)"
                }
        }
    }
    End
    {
    }
}