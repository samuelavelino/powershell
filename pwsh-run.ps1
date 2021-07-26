$run=$args[0]

try
{
    switch ( $run )
    {
        ({$run -eq 'td' -or $run -eq 'thumb'})
        {
            $url = 'https://raw.githubusercontent.com/samuelavelino/powershell/main/ThumbnailDownloader/td.ps1'
            iex (New-Object System.Net.WebClient).DownloadString($url)
            Break
        }
        default
        {
            Write-Host "'$run' command not found." -ForegroundColor Red
        }
    }
}
catch
{
    Write-Host "url: $url" -ForegroundColor Yellow
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
