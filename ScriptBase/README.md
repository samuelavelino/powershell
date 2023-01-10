# Script Base
Use these scripts as a base to start a new project

## ScriptBase.ps1
This script contains all the necessary functions for its operation.

## script.ps1
This script imports functions from the functions folder. So you can update each function individually.

## test.ps1
If you want to test script.ps1 run this script. If an error occurs, it will inform the origin of the error.

This script imports [ScriptTest](https://github.com/samuelavelino/powershell/tree/main/ScriptTest) to do the test.

```powershell
# test.ps1
[Net.ServicePointManager]::SecurityProtocol='Tls12'; iex (irm https://bit.ly/ps1test)

Test {
    $path = [IO.Path]::Combine( $PSScriptRoot, 'output' )
    . $PSScriptRoot\script.ps1 -path $path -message $true -log $true
}
```

## Troubleshooting
When you are executing a PowerShell script for the first time you may encounter the following error:
filename.ps1 cannot be loaded because running scripts is disabled on this system.

Open a new session as an administrator and type:

### Command Prompt:
```powershell
powershell Set-ExecutionPolicy RemoteSigned
```

### PowerShell:
```powershell
Set-ExecutionPolicy RemoteSigned -force
```
