# Script Test
An easy way to test a PowerShell script block

## Usage
You don't need to install anything, just import the "test.ps1" file into your script and put your code inside the "Test" function.
See the examples below.

## Exemple

### PowerShell: //importe de uma url
```powershell
# exemple.ps1
[Net.ServicePointManager]::SecurityProtocol='Tls12'; iex (irm https://bit.ly/ps1test)

Test {
    
    throw 'Error generated for test.'

}
```

### Local: //importe de um diretorio
```powershell
# exemple.ps1
. $PSScriptRoot\test.ps1

Test {
    
    throw 'Error generated for test.'

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