<#
.SYNOPSIS
    Test a script block

.DESCRIPTION
    Runs the given script block and returns the execution duration and error source.

.LINK
    https://github.com/samuelavelino/powershell/tree/main/ScriptTest

.NOTES
    Version: 1.1 (2023-01-01)
    Author:  Samuel Avelino
    Contact: avelino.contactme+github(a)gmail.com
    Website: https://samuelavelino.github.io
#>
#=================================================================================
# Version required

#Requires -Version 3

#=================================================================================
# Functions

Function IsISE {

    try {

        if ($psISE) {
            # if it is in PowerShell ISE remove the variables
            Get-Variable | ForEach-Object { Remove-Variable $_.name -ErrorAction SilentlyContinue }
        } else {
            # if not, wait for key press
            Write-Host -f Green "`r`nPress any key to continue..."
            Read-Host
        }

    }
    catch {

        Write-Host -f Green "`r`nPress any key to continue..."
        Read-Host

    }
}
#---------------------------------------------------------------------------------
Function Test ( [ScriptBlock] $scriptBlock ) {

    $sw = New-Object Diagnostics.Stopwatch
         
    try {

        $sw.Start()
        . $scriptBlock
        $sw.Stop()
        
    }
    catch {

        $script = $_.InvocationInfo.ScriptName
        $line = $_.InvocationInfo.ScriptLineNumber
        $char = $_.InvocationInfo.OffsetInLine
        $origin = $_.InvocationInfo.Line
        $msg = $_.Exception.Message
        
        Write-Host -f Red "Error location:"
        Write-Host -f Red "- Script: $script"
        Write-Host -f Red "- Line: $line Char: $char"
        Write-Host -f Red "- Origin: $($origin.Trim())"
        Write-Host -f Red "- Message: $msg"

    }
    finally {

        Write-Host "Test location: $($MyInvocation.ScriptName)"
        Write-Host "Test completed in $($sw.ElapsedMilliseconds)ms"
        Write-Host "Error count: $($error.Count)"
        
        IsISE

    }

}
