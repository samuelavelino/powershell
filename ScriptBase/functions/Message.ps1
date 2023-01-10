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