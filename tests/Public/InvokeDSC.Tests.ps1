Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path "$PSScriptRoot\..\..\InvokeDSC\$ModuleManifestName"
        $? | Should Be $true
    }
}