function Invoke-DSC
{
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