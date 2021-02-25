<#
http://go.microsoft.com/fwlink/?LinkID=135170

When you are executing a PowerShell script for the first time you may encounter the following error:
filename.ps1 cannot be loaded because running scripts is disabled on this system.

Open a new session as an administrator and type:

PowerShell:

Set-ExecutionPolicy RemoteSigned -force

Command Prompt:

powershell Set-ExecutionPolicy RemoteSigned
#>
