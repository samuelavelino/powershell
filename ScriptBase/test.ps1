[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; iex (irm https://bit.ly/ps1test)
#---------------------------------------------------------------------------------
# Test

Test {
    $path = [IO.Path]::Combine( $PSScriptRoot, 'output' )
    . $PSScriptRoot\script.ps1 -path $path -message $true -log $true
}