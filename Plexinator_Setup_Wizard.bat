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
Echo Do You Have All the Prereqs? i.e. Handbreakcli,ffmpeg and filebot?
Echo 1. Yes
Echo 2. No
SET /P PREREQ=
IF %PREREQ%==1 Goto START 
IF %PREREQ%==2 Powershell.exe -executionpolicy remotesigned -File PreReq_Downloader.ps1

:START
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
