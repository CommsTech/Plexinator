#   Install 7zip module
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
Install-Module -Name 7Zip4PowerShell -Force
# Now start Dependancy Download
Set-Variable -Name THEpath -Value (Get-Location).path
Write-Host Now Downloading HandBrakeCLI
Invoke-WebRequest https://github.com/HandBrake/HandBrake/releases/download/1.3.1/HandBrakeCLI-1.3.1-win-x86_64.zip -OutFile ./HandBrakeCLI.zip
Write-Host HandBrakeCLI Download Complete
Write-Host Now Downloading FFMPEG Files
Invoke-WebRequest https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z -OutFile ./ffmpeg.7z
Write-Host FFMPEG Download Complete
Write-Host Now Downloading Filebot
Invoke-WebRequest https://get.filebot.net/filebot/FileBot_4.9.6/FileBot_4.9.6_x64.msi -OutFile ./FileBot.msi
Write-Host FileBot Download Complete
Write-Host Now Downloading videoduplicatefinder
Invoke-WebRequest https://github.com/0x90d/videoduplicatefinder/releases/download/3.0.x/App-win-x64.zip -OutFile ./VDF.zip
Write-Host Now Expanding HandbreakCLI.zip
Expand-Archive -LiteralPath ./HandBrakeCLI.zip -DestinationPath $THEpath -Force
Write-Host Now Expanding ffmpeg.7z
Expand-7Zip -ArchiveFileName ./ffmpeg.7z -TargetPath $THEpath
Write-Host Now Expanding VDF.zip
Expand-Archive -LiteralPath ./VDF.zip -DestinationPath $THEpath\PREREQS\ -Force
Write-Host Now moving HandBrakeCLI.exe to proper directory
Move-Item -Path $THEpath\HandBrakeCLI.exe -Destination $THEpath\PREREQS\HandBrakeCLI.exe
Write-Host Now moving ffmpeg.exe to proper directory
Move-Item -Path $THEpath\ffmpeg-2022-09-15-git-3f0fac9303-full_build\bin\ffmpeg.exe -Destination $THEpath\PREREQS\ffmpeg.exe
Write-Host Now moving ffprobe.exe to proper directory
Move-Item -Path $THEpath\ffmpeg-2022-09-15-git-3f0fac9303-full_build\bin\ffprobe.exe -Destination $THEpath\PREREQS\ffprobe.exe
Write-Host Now moving ffplay.exe to proper directory
Move-Item -Path $THEpath\ffmpeg-2022-09-15-git-3f0fac9303-full_build\bin\ffplay.exe -Destination $THEpath\PREREQS\ffplay.exe
Write-Host Now moving FileBot.msi to proper directory
Move-Item -Path $THEpath\FileBot.msi -Destination $THEpath\PREREQS\FileBot.msi
Write-Host Starting Filebot.msi for install *** Note this is not a silent install and requires input from the user ***
Start-Process .\PREREQS\FileBot.msi
Write-Host Now Removing compressed archives
Remove-Item -Path $THEpath\ffmpeg.7z
Remove-Item -Path $THEpath\HandBrakeCLI.zip
Remove-Item -Path $THEpath\ffmpeg-2022-09-15-git-3f0fac9303-full_build -recurse
Remove-Item -Path $THEpath\VDF.zip
Remove-Item -Path $THEpath\doc -recurse