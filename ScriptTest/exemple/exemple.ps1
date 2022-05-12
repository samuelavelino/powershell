[Net.ServicePointManager]::SecurityProtocol='Tls12'; iex (irm https://bit.ly/ps1test)

Test {

    . $PSScriptRoot\error.ps1

}
