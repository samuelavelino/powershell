param (
    [Alias('P')]$path = [Environment]::GetFolderPath("Desktop"),
    [Alias('D')]$download = [IO.Path]::Combine($path, 'links.txt'),
    [Alias('S')]$size = 'all',
    [Alias('F')]$folderName = "Thumb $(Get-Date -Format "yyyy-MM-dd_HH-mm-ss")",
    [Alias('Sf')]$subFolder = 'id',
    [Alias('O')]$overwrite = $false,
    [Alias('M')]$message = $true,
    [Alias('A')]$archive = $true,
    [Alias('E')]$exec
)

#=================================================================================
# Security Protocol

[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'

#=================================================================================
# Declarations

$quality = @('maxresdefault', 'sddefault', 'hqdefault', 'mqdefault', 'default', '1', '2', '3')
$path = [IO.Path]::Combine($path, $folderName)
$file = [IO.Path]::Combine($path, "archive.txt")

#=================================================================================
# Functions

Function Create-Directory( $path ) {
    <#
    .SYNOPSIS
        Creates a directory.

    .DESCRIPTION
        The function Create-Directory creates any intermediate directories in the path, if needed.

    .PARAMETER Path
        Specifies the path of where you want to create the new directory.
    #>
    if (Test-Path $path -PathType Container) {
        if ($message) { Write-Host "[TD] (Create-Directory) Directory already exists: $path" -f Red }
    }
    else {
        if ($message) { Write-Host "[TD] (Create-Directory) Directory was created: $path" -f Green }
        $null = mkdir -Path $path
    }
}
#---------------------------------------------------------------------------------
Function Get-URL( $download ) {

    if ( $download.Length -eq 11 ) {
        if ($message) { Write-Host "[TD] (Get-URL) ID: $download" -f Green }
        $url = "https://www.youtube.com/watch?v=$download"
    }
    elseif ( $download.Contains('https://www.youtube.com/watch?v=') -or $download.Contains('https://youtu.be/') ) {
        if ($message) { Write-Host "[TD] (Get-URL) URL: $download" -f Green }
        $url = $download
    }
    elseif (Test-Path $download -PathType Leaf) {
        if ($message) { Write-Host "[TD] (Get-URL) FILE: $download" -f Green }
        $url = Get-Content $download
    }
    else {
        if ($message) { Write-Host "[TD] (Get-URL) ERROR: $download" -f Red }
        $url = $download
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
            if ($message) { Write-Host "[TD] (Get-ID) This is not a valid Youtube ID: $id" -f Red }
            return 'exit'
        }
    }
    else {
  
        if ($message) { Write-Host "[TD] (Get-ID) This is not a valid Youtube URL: $url" -f Red }
        return 'exit'
    }
}
#---------------------------------------------------------------------------------
Function Download-File( $address, $fileName ) {

    try
    {
        # Download file
        (New-Object System.Net.WebClient).DownloadFile($address, $fileName)
        if ($message) { Write-Host "[TD] (Download-File) URL: $address" -f Yellow }
        if ($message) { Write-Host "[TD] (Download-File) PATH: $fileName" -f Green }
        return $true
    }
    catch
    {
        if ($message) { Write-Host "[TD] (Download-File) URL: $address" -f Yellow }
        if ($message) { Write-Host "[TD] (Download-File) $_" -f Red }
        return $false
    }
}
#---------------------------------------------------------------------------------
Function Download-Thumbnail( $url ) {

    $folder = $path
    $id = Get-ID $url

    if ($id -eq 'exit') {

        if ($message) { Write-Host "[TD] (Download-Thumbnail) Operation aborted!" -f Yellow }
        if ($archive) { "[E] $url"| Add-Content -Path $file }
    }
    else {

        if ($subFolder -ne 'no') {

            if ($subFolder -eq 'id') {
                $folder = [IO.Path]::Combine($folder, $id)
            }
            else {
                $folder = [IO.Path]::Combine($folder, $subFolder)
            }

            Create-Directory -Path $folder
        }

        foreach ($thumb in $quality) {

            $address = "https://img.youtube.com/vi/$id/$thumb.jpg"
            $fileName = [IO.Path]::Combine($folder, "$id ($thumb).jpg")

            if (Test-Path $fileName -PathType Leaf) {

                if ($message) { Write-Host "[TD] (Download-Thumbnail) The file already exists: $fileName" -f Yellow }
                
                if ($overwrite) {

                    $success = Download-File $address $fileName

                    if ($success -and $exec -ne $null) {
                        if ($message) { Write-Host "[TD] (Download-Thumbnail) Command executed: $exec" -f Yellow }
                        Invoke-Expression "$exec" -ErrorAction Stop
                    }

                    if ($message) { Write-Host "[TD] (Download-Thumbnail) The file was overwritten: $fileName" -f Green }
                }

                if ($size -eq 'best') {break}
            }
            else {

                $success = Download-File $address $fileName

                if ($success -and $exec -ne $null) {
                    if ($message) { Write-Host "[TD] (Download-Thumbnail) Command executed: $exec" -f Yellow }
                    Invoke-Expression "$exec" -ErrorAction Stop
                }

                if ($archive -and $success) { "[S] $url"| Add-Content -Path $file }
                if ($archive -and -not $success) { "[E] $url"| Add-Content -Path $file }
                
                if ($success -and $size -eq 'best') {break}
            }
        }

        if ( (Get-ChildItem -Path $folder) -eq $null) {
            Remove-Item –Path $folder –Recurse -Force
            if ($message) { Write-Host "[TD] (Download-Thumbnail) Folder Deleted: $folder" -f Yellow }
        }
    }
}

#=================================================================================
# Main Block

Create-Directory -Path $path
$download = Get-URL $download

$download | % {

    Download-Thumbnail $_
}

if ( (Get-ChildItem -Path $path) -eq $null) {
    Remove-Item –Path $path –Recurse -Force
    if ($message) { Write-Host "[TD] (Main Block) Folder Deleted: $path" -f Yellow }
}
