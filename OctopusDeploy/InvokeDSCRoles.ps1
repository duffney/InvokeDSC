Import-Module InvokeDSC
$configEnvPath = '#{Path}'
$roles = '#{Roles}'
$roles = $roles -split ','

foreach ($role in $roles) {
    write-output "Role [$role]"
    $config = (Get-ChildItem -Path $configEnvPath -Recurse -File | Where-Object Name -Match ('^'+[regex]::Escape($($role))+'.json$')).FullName

    if ($config) 
    {
        Write-Output "Configuration $role found [$config]"
        $resourceObj = ConvertTo-DSC -Path "$config"
        Write-Output "Invoking DSC [$($resourceObj.resourceName)]"
        Invoke-DSC -resource $resourceObj        
    }
    else
    {
        Write-Output "Configurtion Not Found for [$role]"    
    }
}