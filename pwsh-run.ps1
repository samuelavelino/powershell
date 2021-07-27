param (
    [Alias('T')]$tool,
    [Alias('A')]$arg
)

#=================================================================================
# Function

Function Downloader( $url, $arg ) {

    try
    {
        [Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'
        iex ". {$(irm $url)} $arg"
    }
    catch
    {
        Write-Host "url: $url" -ForegroundColor Yellow
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
}

#=================================================================================
# Main Block

switch ( $tool )
{
    ({$tool -eq 'td' -or $tool -eq 'thumb'})
    {
        Downloader -arg $arg -url 'https://raw.githubusercontent.com/samuelavelino/powershell/main/ThumbnailDownloader/td.ps1'
        Break
    }
    default
    {
        Write-Host "'$tool' command not found." -ForegroundColor Red
    }
}
