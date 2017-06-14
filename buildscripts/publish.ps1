$ErrorActionPreference = 'Stop'

try {
	## Don't upload the build scripts and appveyor.yml to PowerShell Gallery
	$tempmoduleFolderPath = "$env:Temp\InvokeDSC"
	$null = mkdir $tempmoduleFolderPath

	## Move all of the files/folders to exclude out of the main folder
	$excludeFromPublish = @(
		'InvokeDSC\\buildscripts'
		'InvokeDSC\\appveyor\.yml'
		'InvokeDSC\\\.git'
		'InvokeDSC\\README\.md'
		'InvokeDSC\\Tests'
		'InvokeDSC\\LICENSE'
		'InvokeDSC\\.vscode'
	)
	$exclude = $excludeFromPublish -join '|'
	Get-ChildItem -Path $env:APPVEYOR_BUILD_FOLDER -Recurse | where { $_.FullName -match $exclude } | Remove-Item -Force -Recurse

	## Publish module to PowerShell Gallery
	$publishParams = @{
		Path = "$env:APPVEYOR_BUILD_FOLDER\InvokeDSC"
		NuGetApiKey = $env:nuget_apikey
		Repository = 'PSGallery'
		Force = $true
		Confirm = $false
	}
	Publish-Module @publishParams

} catch {
	Write-Error -Message $_.Exception.Message
	$host.SetShouldExit($LastExitCode)
}