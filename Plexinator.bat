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
SET VDF=%~dp0PREREQS\VDF.Windows-x64\VideoDuplicateFinderConsole.exe
SET /a THREADA=%NUMBER_OF_PROCESSORS% / 2 + (%NUMBER_OF_PROCESSORS%/2/2)
IF /I "%THREADA%" LEQ "1" SET /a THREADA=0
SET /P THREADS=Enter the number of threads you want to use ( We recommend %THREADA% )
IF "%THREADS%"=="" SET THREADS=%THREADA%
IF /I "%THREADS%" GEQ "5" SET /a THREADL=4
:VFDIR
echo What is the directory of your video files
SET /P WORK_DIR=Enter your directory here:
IF "%WORK_DIR%"=="" SET WORK_DIR=%~dp0
:HBO
REM HANDBREAK OPTIONS
ECHO What kind of Videos are in this directory?
ECHO 1. Movies (HQ 1080p W/ AAC and AC3 Tracks) Pic Qual Very High
ECHO 2. TV Shows (HQ 720p W/ AAC and AC3 Tracks) Pic Qual High
ECHO 3. Anime (720p W/ AAC Track) Pic Qual Standard
ECHO 4. Live Sports (1080p W/ AAC Track) Pic Qual Average
SET /P HBO1=
IF %HBO1%==1 SET "HBOPTIONS=--preset="HQ 1080p30 Surround" --optimize" 
IF %HBO1%==2 SET "HBOPTIONS=--preset="HQ 720p30 Surround" --optimize"
IF %HBO1%==3 SET "HBOPTIONS=--preset="Fast 720p30" --optimize"
IF %HBO1%==4 SET "HBOPTIONS=--preset="Very Fast 1080p30" --optimize"
SET "HBFILETYPES=*.ts -or *.avi -or *.mov -or *.m4v -or *.flv -or *.MPV -or *.MPEG -or *.WMV"
REM FFMPEG and FFPROBE OPTIONS
SET "ProbeOptions=-loglevel error -show_entries stream=codec_name -of default=nw=1"
SET "MpegOptions=-hide_banner -fflags +genpts+discardcorrupt+fastseek -analyzeduration 100M -probesize 50M -hwaccel dxva2 -y -threads %THREADS% -v error -stats"
SET "FilesFound=0"
SET "FilesEncoded=0"
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
ECHO 1. By the numbers
ECHO 2. Automagic
ECHO 3. Attempt to share the wealth with other computers Automagically (coming soon)
SET /p MENUSELECT=Type Your Choice then press ENTER :
IF %MENUSELECT%==1 goto Submenu
IF %MENUSELECT%==2 goto Automagic
IF %MENUSELECT%==3 goto DISTRIBUTED_MAGIC

:Submenu
echo
echo 1. Duplicate remover
echo 2. Converter
echo 3. Optimizer
echo 4. Filer
echo 5. Tester
echo 6. Automagic
echo 7. New Video Folder

set /p SUBMENUSELECT=Type Your Choice then press ENTER :
IF %SUBMENUSELECT%==1 goto DeDup
IF %SUBMENUSELECT%==2 goto Converter
IF %SUBMENUSELECT%==3 goto Optimizer
IF %SUBMENUSELECT%==4 goto Filer
IF %SUBMENUSELECT%==5 goto Tester
IF %SUBMENUSELECT%==6 goto Automagic
IF %SUBMENUSELECT%==7 goto VFDIR

:DeDup
Title Plexinator - Handbreak Conversion (Step 1.1)
echo Lets start with file de Duplication
%VDF% -i %WORK_DIR% -r -p 96
pause
goto submenu

:Converter
CLS
Title Plexinator - Handbreak Conversion (Step 2)
echo Lets start with file conversions
FOR /F "tokens=*" %%I IN ('DIR /B /S %HBFILETYPES%') do (
    echo File: %FULLFILENAME%
   "%HANDBRAKE_CLI%" -i "%FULLFILENAME%" -o "%TEMPFILENAME%" %HBOPTIONS%
        if not errorlevel 1 (
            move /Y "%TEMPFILENAME%" "%%~dpnI.mp4""
            if not errorlevel 1 set /A FilesEncoded+=1
        )
        if exist "%TEMPFILENAME%" del "%TEMPFILENAME%"
        if exist "%%~dpnI.mp4" del "%FULLFILENAME%"
    )
)
Title Plexinator - FFMPEG REMUX (Step 2.1)
FOR /F "tokens=*" %%I IN ('DIR /B /S *.mkv') do (
    echo File: %FULLFILENAME%
   "%FFMPG%" -i "%FULLFILENAME%" -c copy -map 0 "%TEMPFILENAME%" -movflags faststart
        if not errorlevel 1 (
            move /Y "%TEMPFILENAME%" "%%~dpnI.mp4""
            if not errorlevel 1 set /A FilesEncoded+=1
        )
        if exist "%TEMPFILENAME%" del "%TEMPFILENAME%"
        if exist "%%~dpnI.mp4" del "%FULLFILENAME%"
    )
)
pause
goto submenu

:Optimizer
CLS
Title Plexinator - FFMPEG Optimize (Step 3)
setlocal EnableExtensions DisableDelayedExpansion
set "FilesFound=0"
set "FilesEncoded=0"

for /F "delims=" %%I in ('dir *.mkv *.mp4 /A-D-H /B /S 2^>nul') do (
    set "FullFileName=%%I"
    set "TempFileName=%%~dpnI_new%%~xI"
    set "AudioCodec="
    set "AudioOption=ac3"
    set "VideoCodec="
    set "VideoOption=h264"
    set /A FilesFound+=1

    for /F "eol={ tokens=1,2 delims=,:[ ]{} " %%B in ('"%FFPROB% %ProbeOptions% "%%I""') do (
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
    echo File: !FullFileName!
    echo Video codec: !VideoCodec!
    echo Audio codec: !AudioCodec!
    if not "!VideoOption!" == "!AudioOption!" (
        "%FFMPG%" %MpegOptions% -i "!FullFileName!" -c:v !VideoOption! -c:a !AudioOption! "!TempFileName!"
        if not errorlevel 1 (
            move /Y "!TempFileName!" "!FullFileName!"
            if not errorlevel 1 set /A FilesEncoded+=1
        )
        if exist "!TempFileName!" del "!TempFileName!"
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
Title Plexinator - Handbreak Conversion (Step 1.1)
echo Lets start with file de Duplication
%VDF% -i %WORK_DIR% -r -p 96
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
ECHO N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mkv') DO "%FFMPG%" -i "%%G" -c copy -map 0 "%OUTPUT_DIR%\%%~nG.mp4" -movflags faststart
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