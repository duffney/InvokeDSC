# InvokeDSC
InvokeDSC is a Json based DSL for creating and managing infrastructure with DSC resources.

## Overview
Allows you to declaratively define your infrastructure within json configuration documents. InvokeDSC converts those json documents to PSCustomObjects that Invoke-DSCResource can consume. By doing this it removes the need for PowerShell configuration documents and the .mof documents it generates. Which results in more flexibility and removes the need of a single .mof document that declares the end state of your infrastructure.
