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
IF %PREREQ%==1 Powershell.exe Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -File PREREQS\PreReq_Downloader.ps1 
IF %PREREQ%==2 goto EOF
IF %PREREQ%==3 goto ADDITIONALINFO

:ADDITIONALINFO
SET /P HANDBRAKE_CLI=Enter the full handbreakcli.exe location ex: X:\mine\handbreakcli.exe here:
IF "%HANDBRAKE_CLI%"=="" SET HANDBRAKE_CLI=E:\Plexinator\PREREQS\HandBrakeCLI.exe
SET /P FFMPG=Enter the full ffmpeg.exe location ex: X:\mine\ffmpeg.exe here:
IF "%FFMPG%"=="" SET FFMPG=E:\Plexinator\PREREQS\ffmpeg.exe

:BEGIN
SET /P OUTPUT_DIR=Enter your Video file output directory here:
IF "%OUTPUT_DIR%"=="" SET OUTPUT_DIR=D:\Downloads\Completed
IF "%HANDBRAKE_CLI%"=="" SET HANDBRAKE_CLI=E:\Plexinator\PREREQS\HandBrakeCLI.exe
IF "%FFMPG%"=="" SET FFMPG=E:\Plexinator\PREREQS\ffmpeg.exe
SET /P FILEBOT=Enter the full filebot.exe location ex: X:\mine\filebot.exe here:
IF "%FILEBOT%"=="" SET FILEBOT=C:\Users\terra\AppData\Local\Microsoft\WindowsApps\PointPlanck.FileBot_49ex9gnthnt12\filebot
SET LIBARYCHECK=E:\Plexinator\PREREQS\LibaryCheck.ps1
SET /a THREADA=%NUMBER_OF_PROCESSORS% / 2 + (%NUMBER_OF_PROCESSORS%/2/2)
IF /I "%THREADA%" LEQ "1" SET /a THREADA=0
SET /P THREADS=Enter the number of threads you want to use ( We recommend %THREADA% )
IF "%THREADS%"=="" SET THREADS=%THREADA%
IF /I "%THREADS%" GEQ "5" SET /a THREADL=4
echo What is the directory of your video files
SET /P WORK_DIR=Enter your directory here:
IF "%WORK_DIR%"=="" SET WORK_DIR=C:\

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
FOR /F "tokens=*" %%G IN ('DIR /B /S *.ts -or *.avi -or *.mov -or *.m4v -or *.flv -or *.MPV -or *.MPEG -or *.WMV') DO "%HANDBRAKE_CLI%" -i "%%G" -o "%OUTPUT_DIR%\%%~nG.mp4" --preset="Fast 1080p30" --optimize
Title Plexinator - FFMPEG REMUX (Step 2.1)
ECHO N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mkv') DO "%FFMPG%" -i "%%G" -c copy -map 0 "%OUTPUT_DIR%\%%~nG.mp4" -filter_threads %threads% -filter_complex_threads %threads% -movflags faststart
goto submenu

:Optimizer
CLS
Title Plexinator - FFMPEG optimizer (Step 3)
echo time to optimize exhisting videos
ECHO N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FFMPG%" -i "%%G" -movflags faststart -acodec copy -vcodec copy "%OUTPUT_DIR%\%%~nG.mp4" -filter_threads %threads% -filter_complex_threads %threads%
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
Powershell.exe Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -File "%LIBARYCHECK%" -dir "%WORK_DIR%" -threads "%THREADL%"
goto submenu

:Automagic
echo Automagiclly starting
Title Plexinator - Handbreak Conversion (Step 2)
echo Lets start with file conversions
FOR /F "tokens=*" %%G IN ('DIR /B /S *.ts -or *.avi -or *.mov -or *.m4v -or *.flv -or *.MPV -or *.MPEG -or *.WMV') DO "%HANDBRAKE_CLI%" -i "%%G" -o "%OUTPUT_DIR%\%%~nG.mp4" --preset="Fast 1080p30" --optimize
Title Plexinator - FFMPEG REMUX (Step 2.1)
ECHO N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mkv') DO "%FFMPG%" -i "%%G" -c copy -map 0 "%OUTPUT_DIR%\%%~nG.mp4" -filter_threads %threads% -filter_complex_threads %threads% -movflags faststart
Title Plexinator - FFMPEG optimizer (Step 3)
echo time to optimize exhisting videos
ECHO N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FFMPG%" -i "%%G" -movflags faststart -acodec copy -vcodec copy "%OUTPUT_DIR%\%%~nG.mp4" -filter_threads %threads% -filter_complex_threads %threads%
Title Plexinator - FileBot Orginiation (Step 4)
echo lets put those files where they belong
FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FILEBOT%" -rename "%%G" -script fn:amc --output "%OUTPUT_DIR%" --action move --conflict skip -non-strict --log-file amc.log --def unsorted=n music=y artwork=n clean=y movieFormat="%OUTPUT_DIR%\Movies\{n} ({y})\{n} ({y})" seriesFormat="%OUTPUT_DIR%\TV Shows\{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t.replaceAll(/[`´‘’ʻ]/, /'/).replaceAll(/[!?.]+$/).replacePart(', Part $1')}{'.'+lang}" "ut_label=%L" "ut_state=%S" "ut_title=%N" "ut_kind=%K" "ut_file=%F" "ut_dir=%D"
Title Plexinator - Handbreak Tester (Step 5)
echo Time to list the files with possible playback issues
Powershell.exe Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -File "%LIBARYCHECK%" -dir "%WORK_DIR%" -threads "%THREADL%"
goto Menu

:DISTRIBUTED_MAGIC
rem future magic

:EOF
pause
