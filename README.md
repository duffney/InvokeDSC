[![Build status](https://ci.appveyor.com/api/projects/status/0ybs7owjkn14ro35?svg=true)](https://ci.appveyor.com/project/Duffney/invokedsc)

# InvokeDSC
InvokeDSC is a JSON based DSL for creating and managing infrastructure with DSC resources.

## Overview
Allows you to declaratively define your infrastructure within JSON configuration documents. InvokeDSC converts those json documents to PSCustomObjects that Invoke-DSCResource can consume. By doing this it removes the need for PowerShell configuration documents and the .mof documents it generates. Which results in more flexibility and removes the need of a single .mof document that declares the end state of your infrastructure.


![test run output](doc/readme/InvokeDSC.jpg)



## JSON Configuration File

```JSON
{
    "Modules":{
        "xPSDesiredStateConfiguration":"8.0.0.0"
    },
   "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
   }
}
```

## Commands

* ConvertTo-Dsc
* Invoke-Dsc
* Invoke-DscConfiguration

## Examples


### Invoke-DscConfiguration

```PowerShell
Invoke-DscConfiguration -Path 'c:\config.json'
```

```PowerShell
$config = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":"8.0.0.0"
    },
   "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
   }
}
"@

Invoke-DscConfiguration -InputObject $config
```


### ConvertTo-Dsc

```PowerShell
ConvertTo-Dsc -Path 'c:\json\example.json'
```

```PowerShell
$config = @"
{
    "Modules":{
        "xPSDesiredStateConfiguration":"8.0.0.0"
    },
   "DSCResourcesToExecute":{
        "DevOpsGroup":{
            "dscResourceName":"xGroup",
            "GroupName":"DevOps",
            "ensure":"Present"
        }
   }
}
"@

ConvertTo-Dsc -InputObject $config
```

### Invoke-Dsc

```powershell
$r = ConvertTo-Dsc -Path 'c:\config.json'
Invoke-Dsc -Resource $r
```


### Credits

[POSHOrigin](https://github.com/devblackops/POSHOrigin) by [Brandon Olin](https://github.com/devblackops)


[Ansible-win_dsc](https://github.com/trondhindenes/Ansible-win_dsc) by [Trond Hindenes](https://github.com/trondhindenes)


[Steven Murawski](https://github.com/smurawski)


[Jaigene Kang](https://twitter.com/prattlesnake)
