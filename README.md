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
          "destinationPath":"c:\\Paylocity\\Service\\file.txt",
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
