@echo off
REM -------------------------------------------------------------------------------------------------------------------------
REM Setup Console view
REM -------------------------------------------------------------------------------------------------------------------------
Title Plexinator Setup Wizard
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

SET /P OUTPUT_DIR=Enter your Video file output directory here:
IF "%OUTPUT_DIR%"=="" SET OUTPUT_DIR=D:\Downloads\Completed
SET /P HANDBRAKE_CLI=Enter the full handbreakcli.exe location ex: X:\mine\handbreakcli.exe here:
IF "%HANDBRAKE_CLI%"=="" SET HANDBRAKE_CLI=E:\Plexinator\handbrakecli.exe
SET /P FFMPG=Enter the full ffmpeg.exe location ex: X:\mine\ffmpeg.exe here:
IF "%FFMPG%"=="" SET FFMPG=E:\Plexinator\ffmpeg.exe
SET /P FILEBOT=Enter the full filebot.exe location ex: X:\mine\filebot.exe here:
IF "%FILEBOT%"=="" SET FILEBOT=C:\Users\terra\AppData\Local\Microsoft\WindowsApps\PointPlanck.FileBot_49ex9gnthnt12\filebot
SET /P LIBARYCHECK=Enter the full Libarycheck.ps1 location ex:X:\mine\LibaryCheck.ps1 here:
IF "%LIBARYCHECK%"=="" SET LIBARYCHECK=E:\Plexinator\LibaryCheck.ps1
SET /a THREADA=%NUMBER_OF_PROCESSORS% / 2 + (%NUMBER_OF_PROCESSORS%/2/2)
IF /I "%THREADA%" LEQ "1" SET /a THREADA=0
SET /P THREADS=Enter the number of threads you want to use ( We recommend %THREADA% )
IF "%THREADS%"=="" SET THREADS=%THREADA%

(
echo ^{
echo "SET OUTPUT_DIR = %OUTPUT_DIR%"
echo "SET HANDBRAKE_CLI = %HANDBRAKE_CLI%"
echo "SET FFMPG = %FFMPG%"
echo "SET FILEBOT = %FILEBOT%"
echo "SET LIBARYCHECK = %LIBARYCHECK%"
echo "SET THREADS = %THREADS%"
) > Settings.conf

:Installers
:GET_HandbreakCLI
if exist Handbreakcli.exe echo File already exists!&pause&goto :GET_FFMPEG
start "Handbreacli Setup" wget -N https://handbrake.fr/downloads2.php >nul 2>&1
if exist Handbreakcli.exe (echo File download successful.) else (echo File download UNSUCCESSFUL.) goto :Get_HandbreakCLI
start Handbreakcli.exe

:GET_FFMPEG
if exist ffmpeg.exe echo File already exists!&pause&goto :GET_FILEBOT
start "FFMPEG Setup" wget -N https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-20200121-fc6fde2-win64-static.zip >nul 2>&1
if exist ffmpeg-20200121-fc6fde2-win64-static.zip (echo File download successful.) else (echo File download UNSUCCESSFUL.)
start ffmpeg-20200121-fc6fde2-win64-static.zip

:GET_FILEBOT
if exist filebot.exe echo File already exists!&pause&goto :EOF
start "FILEBOT Setup" wget -N https://get.filebot.net/filebot/FileBot_4.8.5/FileBot_4.8.5_x64.msi >nul 2>&1
if exist FileBot_4.8.5_x64.msi (echo File download successful.) else (echo File download UNSUCCESSFUL.)
start FileBot_4.8.5_x64.msi
goto installers
:EOF
echo All Setup
pause
