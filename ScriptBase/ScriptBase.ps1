<#
.SYNOPSIS
	An script base example.

.DESCRIPTION
	Use as a base to create a new script.

.PARAMETER Path
    Specifies the path where the logs will be saved. (Default = Desktop)

.PARAMETER LogFile
    Specifies the log file where the logs will be recorded. (Default = "log (yyyy-MM-dd_HH-mm-ss).txt")

.PARAMETER Message
    If the value is true, it will display system messages. (Default = True)
    
.PARAMETER Log
    If the value is true, record the system messages in the log file. (Default = True)

.EXAMPLE
    PS> .\ScriptBase.ps1
	Example of how to use this cmdlet.

.EXAMPLE
    PS> .\ScriptBase.ps1 -path $HOME -message $false -log $false
	Another example of how to use this cmdlet.

.LINK
    https://github.com/samuelavelino/powershell/tree/main/ScriptBase

.NOTES
    Version: 1.0 (2023-01-10)
    Author:  Samuel Avelino
    Contact: avelino.contactme+github(a)gmail.com
    Website: https://samuelavelino.github.io
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
# Declarations

$scriptVersion = 'v1.0'
$scriptName = (Get-Item $PSCommandPath ).Basename

$date = Get-Date -Format (Get-Culture).DateTimeFormat.FullDateTimePattern
$title = "Hi $([Environment]::UserName), welcome to the $scriptName $scriptVersion ($date)"

#---------------------------------------------------------------------------------

$ErrorActionPreference = 'stop'
Set-StrictMode -Version 3.0


#=================================================================================
# Functions

Function Message ( $origin, [ValidateSet('success', 'error','alert', 'info')]$type, $text, $value ) {
    <#
    .SYNOPSIS
        Print system messages

    .DESCRIPTION
        The Message function prints system messages and saves them in the log file.

    .PARAMETER Origin
        To know the origin of the invocation of this function.

    .PARAMETER Type
        The message type. The acceptable values for this parameter are:

        - success
            It must be used when completing a task without errors (prints messages in green color).
        - error
            It must be used when an error occurs (prints the messages in red color).
        - alert
            It must be used to alert about something that has happened (prints messages in yellow color).
        - info
            It must be used to inform about something that happened (prints messages in cyan color).

    .PARAMETER Text
        The string that will be displayed in the console.

    .PARAMETER Value
        The value that will be displayed in the console.

    .NOTES
        Version: 1.0 (2023-01-10)
        Author:  Samuel Avelino
        Contact: avelino.contactme+github(a)gmail.com
        Website: https://samuelavelino.github.io
    #>

    $color = switch ( $type )
    {
        success { 'Green' }
        error { 'Red' }
        alert { 'Yellow' }
        info { 'Cyan' }
        default { 'White' }
    }
    
    if ( ! [String]::IsNullOrWhiteSpace($type) ) { $string += "[$($type.ToUpper())] " }
    $string += "Line: $($MyInvocation.ScriptLineNumber)"
    if ( ! [String]::IsNullOrWhiteSpace("$($origin.InvocationName)") -and ! $origin.MyCommand.name.Contains('.ps1') ) { $string += " - Function: $($origin.InvocationName)" }
    if ( ! [String]::IsNullOrWhiteSpace($text) ) { $string += " - Message: $text" }
    if ( ! [String]::IsNullOrWhiteSpace($value) ) { $string += " - Value: $value" }

    if ( $message ) { Write-Host $string -f $color }

    if ( $log -and ![String]::IsNullOrWhiteSpace($logFile) ) {
        $logRecord = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') - $string"
        $logRecord | Add-Content -LiteralPath "$logFile" -Encoding UTF8
    }
}
#---------------------------------------------------------------------------------
Function Create-Directory ( $path ) {
    <#
    .SYNOPSIS
        Creates a directory.

    .DESCRIPTION
        The Create-Directory function creates any intermediate directories in the path, if needed.

    .PARAMETER Path
        Specifies the path where you want to create the new directory.

    .NOTES
        Version: 1.0 (2023-01-10)
        Author:  Samuel Avelino
        Contact: avelino.contactme+github(a)gmail.com
        Website: https://samuelavelino.github.io
    #>

    if ( [String]::IsNullOrWhiteSpace($path) ) {

        Message -Origin $MyInvocation -Type error -Text 'The $path argument is null or empty'

    }
    else {

        if ( Test-Path -LiteralPath $path -PathType Container ) {
            Message -Origin $MyInvocation -Type 'alert' -Text 'Directory already exists' -Value $path
        }
        else {
            try
            {
                $null = mkdir -Path $path -Force -ErrorAction STOP
                #new-item -type directory -path $path -Force
                Message -Origin $MyInvocation -Type 'success' -Text 'Directory was created' -Value $path
            }
            catch
            {
                Message -Origin $MyInvocation -Type 'error' -Text 'Directory not created' -Value $path
                Message -Origin $MyInvocation -Type 'error' -Value $_
            }
        }
    }

    return $path
}


#=================================================================================
# Main Block

$path = Create-Directory $path

Message -Origin $MyInvocation -Type alert -Text $title -Value $path
$Host.UI.RawUI.WindowTitle = $title