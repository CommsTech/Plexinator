@echo off
REM -------------------------------------------------------------------------------------------------------------------------
REM Setup Console view
REM -------------------------------------------------------------------------------------------------------------------------
Title Plexinator
REM --------------------------------------------------------------------------------------------------------------------------
REM Disclosure Agreement
REM --------------------------------------------------------------------------------------------------------------------------
echo **************************************************
echo *                                                *
echo * This is a tool to  assist in the optimization  *
echo * of you plex video files.                       *
echo * The creator of this software holds no          *
echo * liability.                                     *
echo * Special Thanks to the developers of:           *
echo * HandbreakCLI, FFMPEG and FileBot               *
echo *                                                *
echo *                                                *
echo *   That being said....                          *
echo *      Let's continue!                           * 
echo *                                                *
echo **************************************************
echo *             Press ENTER to start               *
echo ************************************************** 
pause

:START
REM ------------------------------------------------------------------------------------------------------------------------
REM Gather information and set Variables
REM ------------------------------------------------------------------------------------------------------------------------

CLS
Title Plexinator - Setup (Step 1)
REM set program locations
echo What is the directory of your video files
SET /P WORK_DIR=Enter your directory here:
IF "%WORK_DIR%"=="" SET WORK_DIR=C:\
SET /P OUTPUT_DIR=Enter your Video file output directory here:
IF "%OUTPUT_DIR%"=="" SET OUTPUT_DIR=D:\Downloads\Completed
SET /P HANDBRAKE_CLI=Enter the full handbreakcli.exe location ex: X:\mine\handbreakcli.exe here:
IF "%HANDBRAKE_CLI%"=="" SET HANDBRAKE_CLI=C:\Users\terra\Desktop\corrupted-media-scanner-master\handbrakecli.exe
SET /P FFMPG=Enter the full ffmpeg.exe location ex: X:\mine\ffmpeg.exe here:
IF "%FFMPG%"=="" SET FFMPG=C:\Program Files\HandBrake\ffmpeg-4.2.1-win64-static\bin\ffmpeg.exe
SET /P FILEBOT=Enter the full filebot.exe location ex: X:\mine\filebot.exe here:
IF "%FILEBOT%"=="" SET FILEBOT=C:\Users\terra\AppData\Local\Microsoft\WindowsApps\PointPlanck.FileBot_49ex9gnthnt12\filebot
SET /P LIBARYCHECK=Enter the full Libarycheck.ps1 location ex:X:\mine\LibaryCheck.ps1 here:
IF "%LIBARYCHECK%"=="" SET LIBARYCHECK=C:\Users\terra\Desktop\corrupted-media-scanner-master\LibaryCheck.ps1

CD /D %WORK_DIR%

:Converter
CLS
Title Plexinator - Handbreak Conversion (Step 2)
echo Lets start with file conversions
FOR /F "tokens=*" %%G IN ('DIR /B /S *.ts -or *.avi -or *.mov -or *.m4v -or *.flv -or *.MPV -or *.MPEG -or *.WMV') DO "%HANDBRAKE_CLI%" -i "%%G" -o "%OUTPUT_DIR%\%%~nG.mp4" --preset="Fast 1080p30" --optimize

:Optimizer
CLS
Title Plexinator - FFMPEG optimizer (Step 3)
echo time to optimize exhisting videos
ECHO N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FFMPG%" -i "%%G" -movflags faststart -acodec copy -vcodec copy "%OUTPUT_DIR%\%%~nG.mp4" -threads 0

:Filer
CLS
Title Plexinator - FileBot Orginiation (Step 4)
echo lets put those files where they belong
FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FILEBOT%" -rename "%%G" -script fn:amc --output "%OUTPUT_DIR%" --action move --conflict skip -non-strict --log-file amc.log --def unsorted=n music=y artwork=n clean=y movieFormat="%OUTPUT_DIR%\Movies\{n} ({y})\{n} ({y})" seriesFormat="%OUTPUT_DIR%\TV Shows\{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t.replaceAll(/[`´‘’ʻ]/, /'/).replaceAll(/[!?.]+$/).replacePart(', Part $1')}{'.'+lang}" "ut_label=%L" "ut_state=%S" "ut_title=%N" "ut_kind=%K" "ut_file=%F" "ut_dir=%D"

:tester
CLS
Title Plexinator - Handbreak Tester (Step 5)
echo Time to list the files with possible playback issues
Powershell.exe -File "%LIBARARYCHECK%"
pause
