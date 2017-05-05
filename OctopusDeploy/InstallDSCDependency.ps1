Import-Module InvokeDSC

if ($Recurse)
{
    Write-Output "Parsing [$Path] Recurse [true]"

    Get-DSCResourceModule -Path '#{Path}' -Recurse | ForEach-Object `
    {
        Write-Output "Found module [$_]";
        Install-DSCResourceModule -Name $_
    }
}
else
{
    Write-Output "Parsing [$Path] Recurse [false]"

    Get-DSCResourceModule -Path '#{Path}' | Foreach-Object `
    {
        Write-Output "Found module [$_]";Install-DSCResourceModule -Name $_
    }
}