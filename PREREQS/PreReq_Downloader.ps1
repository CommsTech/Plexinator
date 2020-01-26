Set-Variable -Name THEpath -Value (Get-Location).path
Invoke-WebRequest https://github.com/HandBrake/HandBrake/releases/download/1.3.1/HandBrakeCLI-1.3.1-win-x86_64.zip -OutFile HandBrakeCLI.zip
Invoke-WebRequest https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-20200121-fc6fde2-win64-static.zip -OutFile ./ffmpeg.zip
Invoke-WebRequest https://get.filebot.net/filebot/FileBot_4.8.5/FileBot_4.8.5_x64.msi -OutFile ./FileBot_4.8.5_x64.msi
Expand-Archive -LiteralPath ./HandBrakeCLI.zip -DestinationPath $THEpath -Force
Expand-Archive -LiteralPath ./ffmpeg.zip -DestinationPath $THEpath -Force
Move-Item -Path $THEpath\HandBreakCLI.exe -Destination $THEpath\PREREQS\HandBreakCLI.exe
Move-Item -Path $THEpath\ffmpeg-20200121-fc6fde2-win64-static\bin\ffmpeg.exe -Destination $THEpath\PREREQS\ffmpeg.exe
Move-Item -Path $THEpath\ffmpeg-20200121-fc6fde2-win64-static\bin\ffprobe.exe -Destination $THEpath\PREREQS\ffprobe.exe
Move-Item -Path $THEpath\FileBot_4.8.5_x64.msi -Destination $THEpath\PREREQS\FileBot_4.8.5_x64.msi
Start-Process .\PREREQS\FileBot_4.8.5_x64.msi
Remove-Item -Path $THEpath\ffmpeg.zip
Remove-Item -Path $THEpath\HandBrakeCLI.zip
Remove-Item -Path $THEpath\ffmpeg-20200121-fc6fde2-win64-static -recurse
Remove-Item -Path $THEpath\doc -recurse