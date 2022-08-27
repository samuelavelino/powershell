<#
.SYNOPSIS
    Download the thumbnails from YouTube.

.DESCRIPTION
    This script allows you to download all the thumbnails you want.

.PARAMETER Path
    Specifies the path where the thumbnails will be saved. (Default = '\Desktop\Thumb (yyyy-MM-dd_HH-mm-ss)')

.PARAMETER FilePath
    Specifies the path and name of the thumbnails. (Default = '$numb - [$id] $title ($quality).jpg')

.PARAMETER Download
    Accepts a video id, a URL or the path to a file with multiple ids/URLs. (Default = '\Desktop\urls.txt')

.PARAMETER Size
    Specifies whether to download all qualities or just the best. (Default = best)
    
    The acceptable values for this parameter are:

    - all
        Download all available images.
    - best
        Download only the best quality.

.PARAMETER Message
    If the value is true, it displays system messages. (Default = True)
    
.PARAMETER Log
    If the value is true, saves system messages to the log file. (Default = True)
    
.PARAMETER Archive
    If the value is true, save the URLs to the archive file. (Default = True)

.PARAMETER Json
    Specifies the path and name of the json file where the video data will be saved. (Default = '$numb - [$id] $title')
    
.PARAMETER Exec
    A command that will be executed after downloading each thumbnail.

.EXAMPLE
    PS> .\td.ps1
    By default, it will download only the best quality of each URL from the urls.txt file.

.EXAMPLE
    PS> .\td.ps1 -download jNQXAC9IVRw
    It will download only a YouTube thumbnail with a video ID.

.EXAMPLE
    PS> .\td.ps1 -download https://www.youtube.com/watch?v=jNQXAC9IVRw
    It will download only a YouTube thumbnail with a video URL.

.EXAMPLE
    PS> .\td.ps1 -filePath '$numb - [$id] $title\$quality.jpg' -size all -json '$numb - [$id] $title\data'
    Create subfolders for each thumbnail, download all thumbnail images and save the json file.

.EXAMPLE
    PS> .\td.ps1 -filePath '$numb - [$id] $title\$quality.jpg' -size all -json $false
    Create subfolders for each thumbnail, download all thumbnail images and don't save the json file.

.EXAMPLE
    PS> .\td.ps1 -exec 'rni –l $fileName -n "$title.jpg"'
    It will run a command (changes the thumbnail name to the video title) when downloading each thumbnail.

.LINK
    https://github.com/samuelavelino/powershell/tree/main/ThumbnailDownloader

.NOTES
    Version: 2.12 (2022-08-27)
    Author: Samuel Avelino
    Contact: avelino.contactme+github@gmail.com
    Website: https://samuelavelino.github.io
#>
#=================================================================================
# Version required

#Requires -Version 3

#=================================================================================
# Parameters

param (
    [Alias('P')]$path = [IO.Path]::Combine( [Environment]::GetFolderPath('Desktop'), "Thumb ($(Get-Date -f 'yyyy-MM-dd_HH-mm-ss'))"),
    [Alias('F')][string]$filePath = '$numb - [$id] $title ($quality).jpg',
    [Alias('D')]$download = [IO.Path]::Combine( [Environment]::GetFolderPath("Desktop"), 'urls.txt'),
    [Alias('S')][ValidateSet('best', 'all')][string]$size = 'best',
    [Alias('M')][bool]$message = $true,
    [Alias('L')][bool]$log = $true,
    [Alias('A')][bool]$archive = $true,
    [Alias('J')][string]$json = '$numb - [$id] $title',
    [Alias('E')][string]$exec
)

#=================================================================================
# Security Protocol

[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'

#=================================================================================
# Declarations

$ProgressPreference = 'SilentlyContinue'

$date = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$qualities = @('maxresdefault', 'sddefault', 'hqdefault', 'mqdefault', 'default', '1', '2', '3')
$logFile = [IO.Path]::Combine($path, "log ($date).txt")
$archiveFile = [IO.Path]::Combine($path, "archive ($date).txt")

$Global:numb = 1
$Global:errorCount = 0
$Global:successCount = 0

#=================================================================================
# Functions

Function Message( $origin, $type, $text, $value ) {
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
    #>

    $color = switch ( $type )
    {
        success { 'Green' }
        error { 'Red' }
        alert { 'Yellow' }
        info { 'Cyan' }
        default { 'White' }
    }

    if ( ! "$type" -eq "" ) { $string += "[$($type.ToUpper())] " }
    $string += "Line: $($origin.ScriptLineNumber)"
    if ( ! "$($origin.InvocationName)" -eq "" -and ! $origin.MyCommand.name.Contains('.ps1') ) { $string += " - Function: $($origin.InvocationName)" }
    if ( ! "$text" -eq "" ) { $string += " - Message: $text" }
    if ( ! "$value" -eq "" ) { $string += " - Value: $value" }

    if ( $message ) { Write-Host $string -f $color }

    if ( $log -and $download -ne $null ) {
        $logString = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') - $string"
        $logString | Add-Content -LiteralPath $logFile -ErrorAction SilentlyContinue -Encoding UTF8
    }
}
#---------------------------------------------------------------------------------
Function Create-Directory( $path ) {
    <#
    .SYNOPSIS
        Creates a directory.

    .DESCRIPTION
        The Create-Directory function creates any intermediate directories in the path, if needed.

    .PARAMETER Path
        Specifies the path where you want to create the new directory.
    #>

    $path = [IO.Path]::GetDirectoryName($path)

    if ( Test-Path -LiteralPath $path -PathType Container ) {
        Message -Origin $MyInvocation -Type 'alert' -Text 'Directory already exists' -Value $path
    }
    else {
        try
        {
            $null = mkdir -Path $path -ErrorAction STOP
            Message -Origin $MyInvocation -Type 'success' -Text 'Directory was created' -Value $path
        }
        catch
        {
            Message -Origin $MyInvocation -Type 'error' -Text 'Directory not created' -Value $path
            Message -Origin $MyInvocation -Type 'error' -Value $_
        }
    }

    return $path
}
#---------------------------------------------------------------------------------
Function Get-URL( $download ) {
    <#
    .SYNOPSIS
        Get the video URL.

    .DESCRIPTION
        The Get-URL function returns the video URLs you want to download the thumbnails from.

    .PARAMETER Download
        Accepts a video id, a URL or the path to a file with multiple ids/URLs.
    #>

    if ( $download.Length -eq 11 ) {
        Message -Origin $MyInvocation -Type 'success' -Text 'Download from a ID' -Value $download
        $url = "https://www.youtube.com/watch?v=$download"
    }
    elseif ( $download.Contains('youtube.com/watch?v=') -or $download.Contains('youtu.be/') -or $download.Contains('youtube.com/shorts/') ) {
        Message -Origin $MyInvocation -Type 'success' -Text 'Download from a URL' -Value $download
        $url = $download
    }
    elseif ( Test-Path -LiteralPath $download -PathType Leaf ) {
        $fileName = Split-Path $download -leaf
        Message -Origin $MyInvocation -Type 'success' -Text "Download all URLs from $fileName file" -Value $download
        $url = Get-Content $download
    }
    else {
        $fileName = Split-Path $download -leaf
        Message -Origin $MyInvocation -Type 'error' -Text "$fileName file not found" -Value $download
        $url = $null
    }

    return $url
}
#---------------------------------------------------------------------------------
Function Get-ID( $url ) {
    <#
    .SYNOPSIS
        Get the video ID.

    .DESCRIPTION
        The Get-ID function returns the video ID.

    .PARAMETER URL
        Specifies the video URL you want to get the ID of.
    #>

    if ( $url.Length -eq 11 ) {
        return $url
    }
    elseif ( $url.Contains('youtube.com/watch?v=') -or $url.Contains('youtu.be/') -or $url.Contains('youtube.com/shorts/') ) {
  
        if ( $url.Contains('youtube.com/watch?v=') ) { 
            $id = (($url -split 'youtube.com/watch?v=', 0, "simplematch")[1])[0..10] -join ''
        }
        if ( $url.Contains('youtu.be/') ) {
            $id = (($url -split 'youtu.be/', 0, "simplematch")[1])[0..10] -join ''
        }
        if ( $url.Contains('youtube.com/shorts/') ) { 
            $id = (($url -split 'youtube.com/shorts/', 0, "simplematch")[1])[0..10] -join ''
        }

        if ( $id.Length -eq 11 ) {
            return $id
        }
        else {
            Message -Origin $MyInvocation -Type 'error' -Text 'This is not a valid Youtube ID' -Value $id
            return 'exit'
        }
    }
    else {
  
        Message -Origin $MyInvocation -Type 'error' -Text 'This is not a valid Youtube URL' -Value $url
        return 'exit'
    }
}
#---------------------------------------------------------------------------------
Function Get-Json ( $id ) {
    <#
    .SYNOPSIS
        Get the video data.

    .DESCRIPTION
        The Get-Json function returns the json with the video data.

    .PARAMETER ID
        Specifies the video ID you want to get the json.
    #>

    $json = ''
    $url = "https://www.youtube.com/watch?v=$id"

    try
    {
        $url = "https://www.youtube.com/oembed?url=$url&format=json"
        $json = Invoke-RestMethod -Uri $url
        <#
        # Resolve serialization limit error
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
        $jsonserial= New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer 
        $jsonserial.MaxJsonLength  = [int]::MaxValue
        $json = $jsonserial.DeserializeObject($json)
        #>
        Message -Origin $MyInvocation -Type 'success' -Text 'Download Youtube video Json' -Value $url
    }
    catch
    {
        Message -Origin $MyInvocation -Type 'error' -Text 'Error when downloading Youtube video Json' -Value $url
        Message -Origin $MyInvocation -Type 'error' -Value $_
    }

    return $json
}
#---------------------------------------------------------------------------------
Function Save-Json ( $videoJson ) {
    <#
    .SYNOPSIS
        Save video data.

    .DESCRIPTION
        The Save-Json function saves the video data in json format.

    .PARAMETER VideoJson
        Specifies the video json you want to save.
    #>

    $fileName = $ExecutionContext.InvokeCommand.ExpandString( $json )
    $jsonFile = [IO.Path]::Combine( $path, "$fileName.json" )

    if ( $json -ne $false ) {
        try
        {
            $videoJson | ConvertTo-Json | Set-Content -LiteralPath $jsonFile -Encoding UTF8
            Message -Origin $MyInvocation -Type 'success' -Text 'Save Youtube video Json' -Value $jsonFile
        }
        catch
        {
            Message -Origin $MyInvocation -Type 'error' -Text 'Error when saving Youtube video Json' -Value $jsonFile
            Message -Origin $MyInvocation -Type 'error' -Value $_
        }
    }
}
#---------------------------------------------------------------------------------
Function Get-Title( $json ) {
    <#
    .SYNOPSIS
        Get the video title.

    .DESCRIPTION
        The Get-Title function returns the video title.

    .PARAMETER Json
        Specifies the video json you want to get the title of.
    #>

    $title = $json.title

    if ($title -eq $null -or $title -eq '') { $title = 'title' }

    $title = $title.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    Message -Origin $MyInvocation -Type 'success' -Text 'Youtube video title' -Value $title

    return $title
}
#---------------------------------------------------------------------------------
Function Download-File( $address, $fileName ) {
    <#
    .SYNOPSIS
        Download and save the thumbnail.

    .DESCRIPTION
        The Download-File function downloads and saves the thumbnail.

    .PARAMETER Address
        Specifies the URL from which the thumbnail will be downloaded.
        
    .PARAMETER FileName
        The path and name where the thumbnail will be saved.
    #>

    try
    {
        # Download file
        (New-Object System.Net.WebClient).DownloadFile($address, $fileName)
        Message -Origin $MyInvocation -Type 'success' -Text 'Download Youtube video thumbnail' -Value $fileName
        return $true
    }
    catch
    {
        Message -Origin $MyInvocation -Type 'error' -Text 'Error when downloading Youtube video thumbnail' -Value $fileName
        Message -Origin $MyInvocation -Type 'error' -Value $_
        return $false
    }
}
#---------------------------------------------------------------------------------
Function Download-Thumbnail( $url ) {
    <#
    .SYNOPSIS
        Download, save and record what has been done.

    .DESCRIPTION
        The Download-Thumbnail function is the main function that downloads, saves and records what has been done.

    .PARAMETER URL
        Specifies the video URL you want to download the thumbnail.
    #>
    
    if ( $url[0] -eq '#' -or $url[0] -eq '/' -or $url[0] -eq ' ' -or $url[0] -eq $null ) {
        Message -Origin $MyInvocation -Type 'info' -Text 'Just a comment' -Value $url
    }
    else {

        $id = Get-ID $url
        $success = $false

        if ( $id -eq 'exit' ) {

            Message -Origin $MyInvocation -Type 'alert' -Text 'Operation aborted!' -Value $id
            if ( $archive ) { $Global:errorCount++; "[E] $url" | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue }
        }
        else {

            $videoJson = Get-Json $id
            
            if ( $filePath.Contains('$title') ) { $title = Get-Title $videoJson }

            foreach ( $quality in $qualities ) {

                $address = "https://img.youtube.com/vi/$id/$quality.jpg"
                $fileName = $ExecutionContext.InvokeCommand.ExpandString($filePath)
                $fileName = [IO.Path]::Combine($path, $fileName)
                $folder = Create-Directory -Path $fileName

                if ( Test-Path -LiteralPath $fileName -PathType Leaf ) {

                    Message -Origin $MyInvocation -Type 'alert' -Text 'The file already exists' -Value $fileName
 
                    if ( $size -eq 'best' ) { break }
                }
                else {

                    $success = Download-File $address $fileName

                    if ( $success -and $exec -ne '' ) {
                        Invoke-Expression $exec -ErrorAction Stop
                        Message -Origin $MyInvocation -Type 'alert' -Text 'Run command' -Value $exec
                    }

                    if ( $success -and $size -eq 'best' ) { break }
                }
            }
            
            if ( $success ) { Save-Json $videoJson }
            
            if ( $success -and $filePath.Contains('$numb') ) { $Global:numb++ }

            if ($archive -and $success) { $Global:successCount++; "[S] $url" | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue -Encoding UTF8 }
            if ($archive -and -not $success) { $Global:errorCount++; "[E] $url" | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue -Encoding UTF8 }

            # Condition: if subfolder is empty - Action: delete
            if ( (Get-ChildItem -LiteralPath $folder) -eq $null ) {
                Remove-Item –LiteralPath $folder –Recurse -Force -ErrorAction Stop
                Message -Origin $MyInvocation -Type 'alert' -Text 'Empty Subfolder Deleted' -Value $folder
            }
        }
    }
}

#=================================================================================
# Main Block

$download = Get-URL $download

if ( $download -ne $null ) {

    $null = Create-Directory $logFile

    $download | ForEach-Object {

        Download-Thumbnail $_
    }

    if ( $archive ) {
        $temp = Get-Content $archiveFile -ErrorAction SilentlyContinue
        "" | Set-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue
        $temp | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue

        $temp = Get-Content $archiveFile -ErrorAction SilentlyContinue
        "[$errorCount] Error count" | Set-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue
        $temp | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue

        $temp = Get-Content $archiveFile -ErrorAction SilentlyContinue
        "[$successCount] Success count" | Set-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue
        $temp | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue
    }

    # Condition: if folder is empty - Action: delete
    if ( (Get-ChildItem -LiteralPath $path) -eq $null ) {
        Remove-Item –LiteralPath $path –Recurse -Force -ErrorAction Stop
        Message -Origin $MyInvocation -Type 'alert' -Text 'Empty Folder Deleted' -Value $path
    }
}
