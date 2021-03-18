$size=$args[0]
$id=$args[1]

$aQuality = @("maxresdefault", "sddefault", "hqdefault", "mqdefault", "default", "1", "2", "3")

$url = "https://img.youtube.com/vi/$id/$($aQuality[0]).jpg"
$path = Get-Location
$file = "$id.jpg"
$output = [IO.Path]::Combine($path, $file)

try
{
    # Download file
    (New-Object System.Net.WebClient).DownloadFile($url, $output)
    Write-Host "url: $url" -ForegroundColor Yellow
    Write-Host "path: $output" -ForegroundColor Green
}
catch
{
    Write-Host "url: $url" -ForegroundColor Yellow
    Write-Host "$_" -ForegroundColor Red
}
