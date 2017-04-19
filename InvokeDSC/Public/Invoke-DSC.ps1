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
                Write-Output "Running Test Method"

                $splat = @{
                    Name = $resource.dscResourceName
                    Property = $resource.Property
                    ModuleName = $resource.ModuleName
                    ErrorAction = 'SilentlyContinue'
                }

                $testResults = Invoke-DscResource @splat -Method Test -ErrorVariable TestError

                if ($TestError) {
                    Write-Error ("Failed to Invoke $($resource.resourceName)" + ($TestError[0].Exception.Message))
                }

                elseif (($testResults.InDesiredState) -ne $true) {
                    Invoke-DscResource @splat -Method Set -ErrorVariable SetError
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