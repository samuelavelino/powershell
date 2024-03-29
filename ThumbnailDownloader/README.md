# ThumbnailDownloader
An easy way to download all the youtube thumbnails you want.
<br>
<br>

## How to use
You can run the "td.ps1" script with PowerShell or copy and paste in the Command Prompt.

See the examples below.
<br>

## Exemples

### To download multiple YouTube thumbnails
Go to your desktop and create a text document called 'urls.txt'. Copy and paste the YouTube URLs you want to download into the file, one URL per line.

Supported Youtube Video URL Formats:
- youtube.com/watch?v=
- youtu.be/
- youtube.com/shorts/

#### Command Prompt:
```powershell
powershell [Net.ServicePointManager]::SecurityProtocol='Tls12'; iex (irm https://bit.ly/pwsh-td)
```
<br>

### To create subfolders for each thumbnail and download all thumbnail images
You must pass to the filePath parameter (-f alias) the '[$id] $title\\$quality.jpg' value and to the size parameter (-s alias) the 'all' value.

#### Command Prompt:
```powershell
# this command saves the json
powershell [Net.ServicePointManager]::SecurityProtocol='Tls12'; iex """. {$(irm http://bit.ly/pwsh-td)} -f '[`$id] `$title\`$quality.jpg' -s all -j '[`$id] `$title\data'"""
```
#### Command Prompt:
```powershell
# this command don't save the json
powershell [Net.ServicePointManager]::SecurityProtocol='Tls12'; iex """. {$(irm http://bit.ly/pwsh-td)} -f '[`$id] `$title\`$quality.jpg' -s all -j `$false"""
```
<br>

### To download only a YouTube thumbnail
You must pass a video id or url to the download parameter (you can use the alias -d).

#### Command Prompt:
```powershell
# passing an id
powershell [Net.ServicePointManager]::SecurityProtocol='Tls12'; iex """. {$(irm http://bit.ly/pwsh-td)} -d jNQXAC9IVRw"""
```
#### Command Prompt:
```powershell
# passing an url
powershell [Net.ServicePointManager]::SecurityProtocol='Tls12'; iex """. {$(irm http://bit.ly/pwsh-td)} -d https://www.youtube.com/watch?v=jNQXAC9IVRw"""
```
<br>

### To execute a command after downloading each thumbnail
You must pass to the exec parameter (-e alias) the value you want to execute.

#### Command Prompt:
```powershell
# change thumbnail name to the video title
powershell [Net.ServicePointManager]::SecurityProtocol='Tls12'; $a='rni –l $fileName -n """$title.jpg"""'; iex """. {$(irm http://bit.ly/pwsh-td)} -e `$a"""
```
<br>
<br>

# Troubleshooting
When you are executing a PowerShell script for the first time you may encounter the following error:
filename.ps1 cannot be loaded because running scripts is disabled on this system.

Open a new session as an administrator and type:

#### Command Prompt:
```powershell
powershell Set-ExecutionPolicy RemoteSigned
```

#### PowerShell:
```powershell
Set-ExecutionPolicy RemoteSigned -force
