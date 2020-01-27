@echo off
REM -------------------------------------------------------------------------------------------------------------------------
REM Setup Console view
REM -------------------------------------------------------------------------------------------------------------------------
Title Plexinator
REM --------------------------------------------------------------------------------------------------------------------------
REM Disclosure Agreement
REM --------------------------------------------------------------------------------------------------------------------------
echo             **************************************************
echo             *                                                *
echo             * This is a tool to  assist in the optimization  *
echo             * of you plex video files.                       *
echo             * The creator of this software holds no          *
echo             * liability.                                     *
echo             * Special Thanks to the developers of:           *
echo             * HandbreakCLI, FFMPEG and FileBot               *
echo             *                                                *
echo             *                                                *
echo             *   That being said....                          *
echo             *      Let's continue!                           * 
echo             *                                                *
echo             **************************************************
echo             *             Press ENTER to start               *
echo             ************************************************** 
pause

:START
REM ------------------------------------------------------------------------------------------------------------------------
REM Gather information and set Variables
REM ------------------------------------------------------------------------------------------------------------------------

CLS
Title Plexinator - Setup (Step 1)
REM set program locations
:Variables
REM ------------------------------------------------------------------------------------------------------------------------
REM Gather information and set Variables
REM ------------------------------------------------------------------------------------------------------------------------
:HBCHECK
IF EXIST "PREREQS\HandBrakeCLI.exe" (
  goto FFMPEGCHECK
) ELSE (
 goto PREREQINSTALL
)
:FFMPEGCHECK
IF EXIST "PREREQS\FFMPEG.exe" (
  goto BEGIN
) ELSE (
 goto PREREQINSTALL
)

:PREREQINSTALL
Echo We cant find Handbreakcli and/ or ffmpeg.
Echo Would you like us to attempt to download and set them up?
Echo 1. Yes
Echo 2. No / Quit
Echo 3. My Files are located in a diffrent folder
SET /P PREREQ=
IF %PREREQ%==1 Powershell.exe -executionpolicy bypass -File PREREQS\PreReq_Downloader.ps1 
IF %PREREQ%==2 goto EOF
IF %PREREQ%==3 goto ADDITIONALINFO

:ADDITIONALINFO
SET /P HANDBRAKE_CLI=Enter the full handbreakcli.exe location ex: X:\mine\handbreakcli.exe here:
IF "%HANDBRAKE_CLI%"=="" SET HANDBRAKE_CLI=%~dp0PREREQS\HandBrakeCLI
SET /P FFMPG=Enter the full ffmpeg.exe location ex: X:\mine\ffmpeg.exe here:
IF "%FFMPG%"=="" SET FFMPG=%~dp0PREREQS\ffmpeg
SET /P FFPROB=Enter the full ffprobe.exe location ex: X:\mine\ffprobe.exe here:
IF "%FFPROB%"=="" SET FFPROB=%~dp0PREREQS\ffprobe

:BEGIN
SET /P OUTPUT_DIR=Enter your Video file output directory here:
IF "%OUTPUT_DIR%"=="" SET OUTPUT_DIR=%~dp0
IF "%HANDBRAKE_CLI%"=="" SET HANDBRAKE_CLI=%~dp0PREREQS\HandBrakeCLI
IF "%FFMPG%"=="" SET FFMPG=%~dp0PREREQS\ffmpeg
SET /P FILEBOT=Enter the full filebot.exe location ex: X:\mine\filebot.exe here:
IF "%FILEBOT%"=="" SET FILEBOT=%~dp0PREREQS\filebot
SET LIBARYCHECK=E:\Plexinator\PREREQS\LibaryCheck.ps1
SET /a THREADA=%NUMBER_OF_PROCESSORS% / 2 + (%NUMBER_OF_PROCESSORS%/2/2)
IF /I "%THREADA%" LEQ "1" SET /a THREADA=0
SET /P THREADS=Enter the number of threads you want to use ( We recommend %THREADA% )
IF "%THREADS%"=="" SET THREADS=%THREADA%
IF /I "%THREADS%" GEQ "5" SET /a THREADL=4
echo What is the directory of your video files
SET /P WORK_DIR=Enter your directory here:
IF "%WORK_DIR%"=="" SET WORK_DIR=%~dp0
REM HANDBREAK OPTIONS
SET "HBOPTIONS=--preset="HQ 1080p30 Surround" --optimize"
SET "HBFILETYPES=*.ts -or *.avi -or *.mov -or *.m4v -or *.flv -or *.MPV -or *.MPEG -or *.WMV"
REM FFMPEG and FFPROBE OPTIONS
set "ProbeOptions=-v quiet -show_entries "stream^^=codec_name" -of json"
set "MpegOptions=-hide_banner -fflags +genpts+discardcorrupt+fastseek -analyzeduration 100M -probesize 50M -hwaccel dxva2 -y -threads %THREADS% -v error -stats"
set "FilesFound=0"
set "FilesEncoded=0"
SET "AudioCodec="
SET "AudioOption=aac"
SET "VideoCodec="
SET "VideoOption=h264"
SET /A FilesFound+=1
REM Overall Options
SET "FULLFILENAME=%%I"
SET "TEMPFILENAME=%%~dpnI_new.mp4"
SET /A FilesFound+=1

CD /D %WORK_DIR%

:Menu
echo
echo 1. By the numbers
echo 2. Automagic
echo 3. Attempt to share the wealth with other computers Automagically (coming soon)
set /p MENUSELECT=Type Your Choice then press ENTER :
IF %MENUSELECT%==1 goto Submenu
IF %MENUSELECT%==2 goto Automagic
IF %MENUSELECT%==3 goto DISTRIBUTED_MAGIC

:Submenu
echo
echo 1. Converter
echo 2. Optimizer
echo 3. Filer
echo 4. Tester
echo 5. Automagic
echo 6. New Video Folder

set /p SUBMENUSELECT=Type Your Choice then press ENTER :
IF %SUBMENUSELECT%==1 goto Converter
IF %SUBMENUSELECT%==2 goto Optimizer
IF %SUBMENUSELECT%==3 goto Filer
IF %SUBMENUSELECT%==4 goto Tester
IF %SUBMENUSELECT%==5 goto Automagic
IF %SUBMENUSELECT%==6 goto BEGIN


:Converter
CLS
Title Plexinator - Handbreak Conversion (Step 2)
echo Lets start with file conversions
FOR /F "tokens=*" %%I IN ('DIR /B /S %HBFILETYPES%') do (
    setlocal EnableDelayedExpansion
    setlocal EnableExtensions DisableDelayedExpansion
set "FilesFound=0"
set "FilesEncoded=0"
    echo(
    echo File: %FULLFILENAME%
   "%HANDBRAKE_CLI%" -i "%FULLFILENAME%" -o "%TEMPFILENAME%" %HBOPTIONS%
        if not errorlevel 1 (
            move /Y "%TEMPFILENAME%" "%%~dpnI.mp4""
            if not errorlevel 1 set /A FilesEncoded+=1
        )
        if exist "%TEMPFILENAME%" del "%TEMPFILENAME%"
        if exist "%%~dpnI.mp4" del "%FULLFILENAME%"
    )
    endlocal
)

if %FilesFound% == 1 (set "PluralS=") else set "PluralS=s"
echo
echo Re-encoded %FilesEncoded% of %FilesFound% video file%PluralS%.
Title Plexinator - FFMPEG REMUX (Step 2.1)
ECHO N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mkv') DO "%FFMPG%" -i "%%G" -c copy -map 0 "%OUTPUT_DIR%\%%~nG.mp4" -filter_threads %threads% -filter_complex_threads %threads% -movflags faststart


:Optimizer
CLS
Title Plexinator - FFMPEG Optimize (Step 3)
setlocal EnableExtensions DisableDelayedExpansion
set "FilesFound=0"
set "FilesEncoded=0"

for /F "delims=" %%I in ('dir *.mp4 /A-D-H /B /S 2^>nul') do (

    for /F "eol={ tokens=1,2 delims=,:[ ]{} " %%B in ('%FFPROB% %ProbeOptions% %%I') do (
        if "%%~B" == "codec_name" (
            if not defined VideoCodec (
                set "VideoCodec=%%~C"
                if "%%~C" == "h264" set "VideoOption=copy"
            ) else (
                set "AudioCodec=%%~C"
                if "%%~C" == "aac" set "AudioOption=copy"
            )
        )
    )
setlocal EnableDelayedExpansion
    echo(
    echo File: %FullFileName%
    echo Video codec: %VideoCodec%
    echo Audio codec: %AudioCodec%
    if not "%VideoOption%" == "%AudioOption%" (
        "%FFMPG%" %MpegOptions% -i "%FullFileName%" -movflags faststart -c:v %VideoOption% -c:a %AudioOption% "%TempFileName%"
        if not errorlevel 1 (
            move /Y "%TempFileName%" "%FullFileName%"
            if not errorlevel 1 set /A FilesEncoded+=1
        )
        if exist "%TempFileName%" del "%TempFileName%"
    )
    endlocal
)

if %FilesFound% == 1 (set "PluralS=") else set "PluralS=s"
echo(
echo Re-encoded %FilesEncoded% of %FilesFound% video file%PluralS%.
endlocal
pause
goto submenu

:Filer
CLS
Title Plexinator - FileBot Orginiation (Step 4)
echo lets put those files where they belong
FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FILEBOT%" -rename "%%G" -script fn:amc --output "%OUTPUT_DIR%" --action move --conflict skip -non-strict --log-file amc.log --def unsorted=n music=y artwork=n clean=y movieFormat="%OUTPUT_DIR%\Movies\{n} ({y})\{n} ({y})" seriesFormat="%OUTPUT_DIR%\TV Shows\{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t.replaceAll(/[`´‘’ʻ]/, /'/).replaceAll(/[!?.]+$/).replacePart(', Part $1')}{'.'+lang}" "ut_label=%L" "ut_state=%S" "ut_title=%N" "ut_kind=%K" "ut_file=%F" "ut_dir=%D"
goto submenu

:Tester
CLS
Title Plexinator - Handbreak Tester (Step 5)
echo Time to list the files with possible playback issues
Powershell.exe -executionpolicy bypass -File "%LIBARYCHECK%" -dir "%WORK_DIR%" -threads "%THREADL%"
goto submenu

:Automagic
echo Automagiclly starting
Title Plexinator - Handbreak Conversion (Step 2)
echo Lets start with file conversions
FOR /F "tokens=*" %%I IN ('DIR /B /S %HBFILETYPES%') do (
    setlocal EnableDelayedExpansion
    echo(
    echo File: %FULLFILENAME%
   "%HANDBRAKE_CLI%" -i "%FULLFILENAME%" -o "%TEMPFILENAME%" %HBOPTIONS%
        if not errorlevel 1 (
            move /Y "%TEMPFILENAME%" "%%~dpnI.mp4""
            if not errorlevel 1 set /A FilesEncoded+=1
        )
        if exist "%TEMPFILENAME%" del "%TEMPFILENAME%"
        if exist "%%~dpnI.mp4" del "%FULLFILENAME%"
    )
    endlocal
)

if %FilesFound% == 1 (set "PluralS=") else set "PluralS=s"
echo
echo Re-encoded %FilesEncoded% of %FilesFound% video file%PluralS%.
Title Plexinator - FFMPEG REMUX (Step 2.1)
ECHO N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mkv') DO "%FFMPG%" -i "%%G" -c copy -map 0 "%OUTPUT_DIR%\%%~nG.mp4" -filter_threads %threads% -filter_complex_threads %threads% -movflags faststart
Title Plexinator - FFMPEG Optimize (Step 3)
setlocal EnableExtensions DisableDelayedExpansion
set "FilesFound=0"
set "FilesEncoded=0"

for /F "delims=" %%I in ('dir *.mp4 /A-D-H /B /S 2^>nul') do (

    for /F "eol={ tokens=1,2 delims=,:[ ]{} " %%B in ('%FFPROB% %ProbeOptions% %%I') do (
        if "%%~B" == "codec_name" (
            if not defined VideoCodec (
                set "VideoCodec=%%~C"
                if "%%~C" == "h264" set "VideoOption=copy"
            ) else (
                set "AudioCodec=%%~C"
                if "%%~C" == "ac3" set "AudioOption=copy"
            )
        )
    )
setlocal EnableDelayedExpansion
    echo(
    echo File: %FullFileName%
    echo Video codec: %VideoCodec%
    echo Audio codec: %AudioCodec%
    if not "%VideoOption%" == "%AudioOption%" (
        "%FFMPG%" %MpegOptions% -i "%FullFileName%" -movflags faststart -c:v %VideoOption% -c:a %AudioOption% "%TempFileName%"
        if not errorlevel 1 (
            move /Y "%TempFileName%" "%FullFileName%"
            if not errorlevel 1 set /A FilesEncoded+=1
        )
        if exist "%TempFileName%" del "%TempFileName%"
    )
    endlocal
)

if %FilesFound% == 1 (set "PluralS=") else set "PluralS=s"
echo(
echo Re-encoded %FilesEncoded% of %FilesFound% video file%PluralS%.
endlocal
Title Plexinator - FileBot Orginiation (Step 4)
echo lets put those files where they belong
FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FILEBOT%" -rename "%%G" -script fn:amc --output "%OUTPUT_DIR%" --action move --conflict skip -non-strict --log-file amc.log --def unsorted=n music=y artwork=n clean=y movieFormat="%OUTPUT_DIR%\Movies\{n} ({y})\{n} ({y})" seriesFormat="%OUTPUT_DIR%\TV Shows\{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t.replaceAll(/[`´‘’ʻ]/, /'/).replaceAll(/[!?.]+$/).replacePart(', Part $1')}{'.'+lang}" "ut_label=%L" "ut_state=%S" "ut_title=%N" "ut_kind=%K" "ut_file=%F" "ut_dir=%D"
Title Plexinator - Handbreak Tester (Step 5)
echo Time to list the files with possible playback issues
Powershell.exe -executionpolicy bypass -File "%LIBARYCHECK%" -dir "%WORK_DIR%" -threads "%THREADL%"
goto Menu

:DISTRIBUTED_MAGIC
rem future magic

:EOF
pause