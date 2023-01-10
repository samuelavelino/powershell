<#
.SYNOPSIS
	Short description

.DESCRIPTION
	Long description

.PARAMETER Path
    Specifies the path where the logs will be saved. (Default = Desktop)

.PARAMETER LogFile
    Specifies the log file where the logs will be recorded. (Default = "log (yyyy-MM-dd_HH-mm-ss).txt")

.PARAMETER Message
    If the value is true, it will display system messages. (Default = True)
    
.PARAMETER Log
    If the value is true, record the system messages in the log file. (Default = True)

.EXAMPLE
    PS> .\script.ps1
	Example of how to use this cmdlet.

.EXAMPLE
    PS> .\script.ps1 -path $HOME -message $false -log $false
	Another example of how to use this cmdlet.

.LINK
    https://github.com/<username>/powershell/tree/main/<ScriptName>

.NOTES
    Version: x.x.x (yyyy-mm-dd)
    Author:  FirstName LastName
    Contact: youremail(a)email.com
    Website: https://www.yoursite.com
#>

#=================================================================================
# Version required

#Requires -Version 3


#=================================================================================
# Parameters

param (
    [Alias('P')]$path =  [Environment]::GetFolderPath('Desktop'),
    [Alias('Lf')]$logFile = [IO.Path]::Combine( $path, "log ($(Get-Date -f 'yyyy-MM-dd_HH-mm-ss')).txt" ),
    [Alias('M')][bool]$message = $true,
    [Alias('L')][bool]$log = $true
)


#=================================================================================
# Security Protocol

#[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'

#=================================================================================
# Libraries

#Add-Type -AssemblyName System.Windows.Forms, Microsoft.VisualBasic


#=================================================================================
# Declarations

$scriptVersion = 'v0.1'
$scriptName = (Get-Item $PSCommandPath ).Basename

$date = Get-Date -Format (Get-Culture).DateTimeFormat.FullDateTimePattern
$title = "Hi $([Environment]::UserName), welcome to the $scriptName $scriptVersion ($date)"

#---------------------------------------------------------------------------------

$ErrorActionPreference = 'stop' #continue
Set-StrictMode -Version 3.0
#$ProgressPreference = 'SilentlyContinue'


#=================================================================================
# Functions

. $PSScriptRoot\functions\Message.ps1
#---------------------------------------------------------------------------------
. $PSScriptRoot\functions\Create-Directory.ps1


#=================================================================================
# Main Block

$path = Create-Directory $path
(get-help Create-Directory).name
Message -Origin $MyInvocation -Type alert -Text $title -Value $path
$Host.UI.RawUI.WindowTitle = $title