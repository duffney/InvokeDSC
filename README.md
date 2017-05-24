[![Build status](https://ci.appveyor.com/api/projects/status/0ybs7owjkn14ro35?svg=true)](https://ci.appveyor.com/project/Duffney/invokedsc)

# InvokeDSC
InvokeDSC is a JSON based DSL for creating and managing infrastructure with DSC resources.

## Overview
Allows you to declaratively define your infrastructure within JSON configuration documents. InvokeDSC converts those json documents to PSCustomObjects that Invoke-DSCResource can consume. By doing this it removes the need for PowerShell configuration documents and the .mof documents it generates. Which results in more flexibility and removes the need of a single .mof document that declares the end state of your infrastructure.

## Example: New File

### JSON Configuration File

```JSON
{
   "DSCResourcesToExecute":[
      {
          "resourceName":"NewFile",
          "dscResourceName":"File",
          "destinationPath":"c:\\DevOps\\Service\\file.txt",
          "type":"File",
          "contents":"Test",
          "attributes":["hidden","archive"],
          "ensure":"Present",
          "force":true
      }
   ]
}
```

### ConvertTo-DSC PSCustomObject

```PowerShell
$Resource = ConvertTo-DSC -Path 'C:\DSC\NewFile.json'
```

### Invoke-DSC

```PowerShell
Invoke-DSC -Resource $Resource -Verbose
```
### Credits

[POSHOrigin](https://github.com/devblackops/POSHOrigin) by [Brandon Olin](https://github.com/devblackops)


[Ansible-win_dsc](https://github.com/trondhindenes/Ansible-win_dsc) by [Trond Hindenes](https://github.com/trondhindenes)


[Steven Murawski](https://github.com/smurawski)