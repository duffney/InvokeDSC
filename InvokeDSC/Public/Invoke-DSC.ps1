function Invoke-DSC
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [object[]]$Resources
    )

    Begin
    {
    }
    Process
    {
        foreach ($resource in $resources) {

            try {
                
                $splat = @{
                    Name = $resource.dscResourceName
                    Property = $resource.Property
                    ModuleName = $resource.ModuleName
                    ErrorAction = 'SilentlyContinue'
                }
                
                Write-Output "[Start Test] [[$($resource.dscResourceName)]$($resource.ResourceName)]"
                $testResults = Invoke-DscResource @splat -Method Test -ErrorVariable TestError -Verbose:$false | Out-Null

                if ($TestError) {
                    Write-Error ("Failed to Invoke $($resource.resourceName)" + ($TestError[0].Exception.Message))
                }

                elseif (($testResults.InDesiredState) -ne $true) {
                    Write-Output "[Start Set] [[$($resource.dscResourceName)]$($resource.ResourceName)]"
                    Invoke-DscResource @splat -Method Set -ErrorVariable SetError -Verbose:$false | Out-Null
                }

                if ($SetError) {
                    Write-Error "Failed to invoke [$($resource.resourceName)] ($SetError[0].Exception.Message)"
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