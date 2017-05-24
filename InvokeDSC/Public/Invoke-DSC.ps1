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

            try {
                
                $splat = @{
                    Name = $r.dscResourceName
                    Property = $r.Property
                    ModuleName = $r.ModuleName
                    ErrorAction = 'SilentlyContinue'
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
            catch [System.Exception] {
                # Exception is stored in the automatic variable _

            }

            }
    }
    End
    {
    }
}