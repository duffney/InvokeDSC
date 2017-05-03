Import-Module InvokeDSC
$Path = '#{Path}'
$ConfigFileName = '#{ConfigFileName}'
$FullPath = $Path+'\'+$ConfigFileName

if (!(Test-Path -Path $Path))
{
    Write-Output "AppConfig not found for [$ConfigFileName]"
} 
else 
{
    Write-Output "Configuration found [$appConfigFileName]"
    $resourceObj = ConvertTo-DSC -Path $FullPath
    Write-Output "Invoking DSC [$($resourceObj.resourceName)]"
    Invoke-DSC -resource $resourceObj
}