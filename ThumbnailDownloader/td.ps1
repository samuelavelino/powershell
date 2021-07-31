#Requires -Version 3

#=================================================================================
# Parameters

param (
    [Alias('P')]$path = [IO.Path]::Combine(([Environment]::GetFolderPath('Desktop')), "Thumb ($(Get-Date -f 'yyyy-MM-dd_HH-mm-ss'))"),
    [Alias('F')]$filePath = '[$id] $title\$thumb.jpg',
    [Alias('D')]$download = [IO.Path]::Combine(([Environment]::GetFolderPath("Desktop")), 'links.txt'),
    [Alias('S')]$size = 'all',
    [Alias('M')]$message = $true,
    [Alias('L')]$log = $false,
    [Alias('A')]$archive = $true,
    [Alias('E')]$exec
)

#=================================================================================
# Security Protocol

[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'

#=================================================================================
# Declarations

$date = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$quality = @('maxresdefault', 'sddefault', 'hqdefault', 'mqdefault', 'default', '1', '2', '3')
$logFile = [IO.Path]::Combine($path, "log ($date).txt")
$archiveFile = [IO.Path]::Combine($path, "archive ($date).txt")

#=================================================================================
# Functions

Function Message( $string, $foregroundColor ) {

    if ($message) { Write-Host $string -f $foregroundColor }

    if ($log -and $download -ne $null) {
        "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') - $string" | Add-Content -LiteralPath $logFile -ErrorAction SilentlyContinue
    }
}
#---------------------------------------------------------------------------------
Function Create-Directory( $path ) {

    $path = [IO.Path]::GetDirectoryName($path)

    if ( Test-Path -LiteralPath $path -PathType Container ) {
        Message "[TD] (Create-Directory) Directory already exists: $path" -f Red
    }
    else {
        try
        {
            $null = mkdir -Path $path -ErrorAction STOP
            Message "[TD] (Create-Directory) Directory was created: $path" -f Green
        }
        catch
        {
            Message "[TD] (Create-Directory) PATH: $path" -f Yellow
            Message "[TD] (Create-Directory) Error: $_" -f Red
        }
    }

    return $path
}
#---------------------------------------------------------------------------------
Function Get-URL( $download ) {

    if ( $download.Length -eq 11 ) {
        Message "[TD] (Get-URL) ID: $download" -f Green
        $url = "https://www.youtube.com/watch?v=$download"
    }
    elseif ( $download.Contains('https://www.youtube.com/watch?v=') -or $download.Contains('https://youtu.be/') ) {
        Message "[TD] (Get-URL) URL: $download" -f Green
        $url = $download
    }
    elseif ( Test-Path -LiteralPath $download -PathType Leaf ) {
        Message "[TD] (Get-URL) FILE: $download" -f Green
        $url = Get-Content $download
    }
    else {
        Message "[TD] (Get-URL) ERROR: $download" -f Red
        $url = $null
    }

    return $url
}
#---------------------------------------------------------------------------------
Function Get-ID( $url ) {

    if ( $url.Contains('https://www.youtube.com/watch?v=') -or $url.Contains('https://youtu.be/') ) {
  
        if ( $url.Contains('https://www.youtube.com/watch?v=') ) { 
            $id = ($url.Replace('https://www.youtube.com/watch?v=',''))[0..10] -join ''
        }
        if ( $url.Contains('https://youtu.be/') ) {
            $id = ($url.Replace('https://youtu.be/',''))[0..10] -join ''
        }

        if ( $id.Length -eq 11 ) {
            return $id
        }
        else {
            Message "[TD] (Get-ID) This is not a valid Youtube ID: $id" -f Red
            return 'exit'
        }
    }
    else {
  
        Message "[TD] (Get-ID) This is not a valid Youtube URL: $url" -f Red
        return 'exit'
    }
}
#---------------------------------------------------------------------------------
Function Get-Title( $url ) {

    $ProgressPreference = 'SilentlyContinue'

    try
    {
        $url = "https://www.youtube.com/oembed?url=$url&format=json"
        $title = (Invoke-RestMethod -Uri $url).title

        Message "[TD] (Get-Title) Youtube title: $title" -f Yellow

        $title = $title.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    }
    catch
    {
        Message "[TD] (Get-Title) URL: $url" -f Yellow
        Message "[TD] (Get-Title) Error: $_" -f Red
    }

    if ($title -eq $null -or $title -eq '') { $title = 'title' }

    return $title
}
#---------------------------------------------------------------------------------
Function Download-File( $address, $fileName ) {

    try
    {
        # Download file
        (New-Object System.Net.WebClient).DownloadFile($address, $fileName)
        Message "[TD] (Download-File) URL: $address" -f Yellow
        Message "[TD] (Download-File) PATH: $fileName" -f Green
        return $true
    }
    catch
    {
        Message "[TD] (Download-File) URL: $address" -f Yellow
        Message "[TD] (Download-File) Error: $_" -f Red
        return $false
    }
}
#---------------------------------------------------------------------------------
Function Download-Thumbnail( $url ) {

    $id = Get-ID $url
    $success = $false

    if ($id -eq 'exit') {

        Message "[TD] (Download-Thumbnail) Operation aborted!" -f Yellow
        if ($archive) { "[E] $url" | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue }
    }
    else {

        if ( $filePath.Contains('$title') ) { $title = Get-Title $url }

        foreach ($thumb in $quality) {

            $address = "https://img.youtube.com/vi/$id/$thumb.jpg"
            $fileName = $ExecutionContext.InvokeCommand.ExpandString($filePath)
            $fileName = [IO.Path]::Combine($path, $fileName)
            $folder = Create-Directory -Path $fileName

            if ( Test-Path -LiteralPath $fileName -PathType Leaf ) {

                Message "[TD] (Download-Thumbnail) The file already exists: $fileName" -f Yellow
 
                if ($size -eq 'best') {break}
            }
            else {

                $success = Download-File $address $fileName

                if ($success -and $exec -ne $null) {
                    Invoke-Expression $exec -ErrorAction Stop
                    Message "[TD] (Download-Thumbnail) Command executed: $exec" -f Yellow
                }

                if ($success -and $size -eq 'best') {break}
            }
        }

        if ($archive -and $success) { "[S] $url" | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue }
        if ($archive -and -not $success) { "[E] $url" | Add-Content -LiteralPath $archiveFile -ErrorAction SilentlyContinue } 
    
        if ( (Get-ChildItem -LiteralPath $folder) -eq $null ) {
            Remove-Item –LiteralPath $folder –Recurse -Force -ErrorAction Stop
            Message "[TD] (Download-Thumbnail) Folder Deleted: $folder" -f Yellow
        }
    }
}

#=================================================================================
# Main Block

$download = Get-URL $download

if ($download -ne $null) {

    $download | ForEach-Object {

        Download-Thumbnail $_
    }

    if ((Get-ChildItem -LiteralPath $path) -eq $null) {
        Remove-Item –LiteralPath $path –Recurse -Force -ErrorAction Stop
        Message "[TD] (Main Block) Folder Deleted: $path" -f Yellow
    }
}
