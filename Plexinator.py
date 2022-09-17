# Rewritten in python .... for WGU degree
import os
import shutil
import subprocess
import sys
import time
from multiprocessing import cpu_count


def quit():
  print("Thank you for using Plexinator.py. The system will now exit")
  time.sleep (5)
  sys.exit()

# -------------------------------------------------------------------------------------------------------------------------
# Setup Console view
# -------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------
# Disclosure Agreement
# --------------------------------------------------------------------------------------------------------------------------
print(
'''
             **************************************************
             *                                                *
             * This is a tool to  assist in the optimization  *
             * of you plex video files.                       *
             * The creator of this software holds no          *
             * liability.                                     *
             * Special Thanks to the developers of:           *
             * HandbreakCLI, FFMPEG and FileBot               *
             *                                                *
             *                                                *
             *   That being said....                          *
             *      Lets continue!                            * 
             *                                                *
             **************************************************
             *             Press ENTER to start               *
             **************************************************
'''
)

# ------------------------------------------------------------------------------------------------------------------------
# Gather information and set Variables
# ------------------------------------------------------------------------------------------------------------------------
cwd = os.getcwd()
# set program locations
# ------------------------------------------------------------------------------------------------------------------------
# Gather information and set Variables
# ------------------------------------------------------------------------------------------------------------------------
HBFILETYPES="*.ts -or *.avi -or *.mov -or *.m4v -or *.flv -or *.MPV -or *.MPEG -or *.WMV -or *.mkv -or *.m2ts"
# FFMPEG and FFPROBE OPTIONS
ProbeOptions = "-loglevel error -show_entries stream=codec_name -of default=nw=1"
MpegOptions = "-hide_banner -fflags +genpts+discardcorrupt+fastseek -analyzeduration 100M -probesize 50M -hwaccel dxva2 -y -threads %THREADS% -v error -stats"
FilesFound = "0"
FilesEncoded = "0"
AudioCodec = ""
AudioOption = "aac"
VideoCodec = ""
VideoOption = "h264"
int(FilesFound) + 1
# Overall Options
FULLFILENAME = "%%I"
TEMPFILENAME = "%%~dpnI_new.mp4"
int(FilesFound) + 1

# ------------------------------------------------------------------------------------------------------------------------
# Configure Menus and Functions
def START():
  from pathlib import Path
  path_to_file = "PREREQS\HandBrakeCLI.exe"
  path = Path(path_to_file)
  if path.is_file():
    FFMPEGCHECK()
  else:
    PREREQINSTALL()  

def FFMPEGCHECK():
  print("Searching for your ffmpg file location")
  BEGIN()


def PREREQINSTALL():
# Do Provide the option to automatically install the program pre-reqs
  print("We cant find Handbreakcli and/ or ffmpeg?")
  selection =  input ('''
  Would you like us to attempt to download and set them up?

  1 = Yes
  2 = My Files are located in a diffrent folder
  3 = No / Exit

  Please Make a selection from 1, 2 or 3
  '''
  )
  # selection=raw_input("Please Select:") 
  if selection == '1': 
    subprocess.call("powershell.exe -executionpolicy bypass -File PREREQS\PreReq_Downloader.ps1")
  elif selection == '2':
    ADDITIONALINFO() 
  elif selection == '3': 
    quit()
  else: 
    print ("Unknown Option Selected!") 

def ADDITIONALINFO():
  HANDBRAKE_CLI = input("Enter the full handbreakcli.exe location ex: X:\mine\handbreakcli.exe here: ")
  print(f"Writing Handbreak CLI location as: {HANDBRAKE_CLI}")
  FFMPG = input("Enter the full ffmpeg.exe location ex: X:\mine\/ffmpeg.exe here: ")
  print(f"Writing FFMPG.exe location as: {FFMPG}")
  FFPROB = input("Enter the full ffprobe.exe location ex: X:\mine\/ffprobe.exe here: ")
  print(f"Writing FFPROB.exe location as: {FFPROB}")
  FILEBOT = input("Enter the full filebot.exe location ex: X:\mine\/filebot.exe here: ")
  print(f"Writing FILEBOT.exe location as: {FILEBOT}")
  BEGIN()

def BEGIN():
  OUTPUT_DIR = input("Enter your Video file output directory here: ")
  print(f"Writing {OUTPUT_DIR} as your output location")
  LIBARYCHECK = "E:\Plexinator\PREREQS\LibaryCheck.ps1"
  VDF = "%~dp0PREREQS\VDF.Windows-x64\VideoDuplicateFinderConsole.exe"
  NUMBER_OF_PROCESSORS = cpu_count()
  THREADA = int(NUMBER_OF_PROCESSORS) // 2 + (int(NUMBER_OF_PROCESSORS)//2//2)
  if int(THREADA) <= 1:
    THREADA = 0
  else:
    print("Failed to identify threads")
  THREADS = input("Enter the number of threads you want to use We recommend: {THREADA}") 
  THREADS = THREADA
  if int(THREADS) >= 5: 
    THREADL=4
  HBO()

def VFDIR():
  WORK_DIR = input("What is the directory of your video files ")

def HBO():
# HANDBREAK OPTIONS Menu selection and setup
  print ("What kind of Videos are in this directory?")
  selection =  input ('''
  What kind of Videos are in this directory?
  [1] Movies (HQ 1080p W/ AAC and AC3 Tracks) Pic Qual Very High
  [2] TV Shows (HQ 720p W/ AAC and AC3 Tracks) Pic Qual High
  [3] Anime (720p W/ AAC Track) Pic Qual Standard
  [4] Live Sports (1080p W/ AAC Track) Pic Qual Average
  [5] Any YIFY Settings (1080p W/AAC Track) Pic Qual High (smaller size)
  [6] Exit

  Please Make a selection from 1, 2, 3, 4, 5 or 6
  ''')

  # selection=raw_input("Please Select:") 
  if selection == '1': 
      HBOPTIONS = '--preset=HQ 1080p30 Surround --optimize'
  elif selection == '2': 
      HBOPTIONS = '--preset=HQ 720p30 Surround --optimize'
  elif selection == '3':
      HBOPTIONS = '--preset=Fast 720p30 --optimize'
  elif selection == '4': 
      HBOPTIONS = '--preset=Very Fast 1080p30 --optimize'
  elif selection == '5':
      HBOPTIONS = '-E ffaac -B 96k -6 stereo -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all --optimize'
  elif selection == '6': 
      quit()
  else: 
      print("Unknown Option Selected!") 
  HOWTORUN()

print("Current working directory: {0}".format(cwd))

print (
    '''
How would you like to proceed?
'''
)

def HOWTORUN():
  print("how would you like this program to run?")
  selection = input ('''
  [1]="By the numbers" 
  [2]="Automagic"
  [3]="Attempt to share the wealth with other computers Automagically (coming soon)"
  [4]="Exit"

  Please Make a selection from 1, 2, 3 or 4
  ''')

  # selection=raw_input("Please Select:") 
  if selection == '1': 
    Submenu()
  elif selection == '2': 
    Automagic()
  elif selection == '3':
    DISTRUBUTED_MAGIC() 
  elif selection == '4': 
    quit()
  else: 
    print("Unknown Option Selected!") 

def Submenu():
  print("Submenu")
  selection = input('''
  [1] = "Duplicate"
  [2] = "Converter"
  [3] = "Optimizer"
  [4] = "Filer"
  [5] = "Tester"
  [6] = "Automagic"
  [7] = "New Video Folder"
  [8] = "Additional Tools"
  [9] = "MKV 2 MP4"

  Please Make a selection from 1, 2, 3, 4, 5, 6, 7, 8 or 9
  ''')
  if selection == '1': 
    DeDup() 
  elif selection == '2': 
    Converter()
  elif selection == '3':
    Optimizer() 
  elif selection == '4': 
    Filer()
  elif selection == '5': 
    Tester() 
  elif selection == '6': 
    Automagic()
  elif selection == '7':
    VFDIR() 
  elif selection == '8': 
    ADDTOOLS()
  elif selection == '9': 
    MKV2MP4()
  else: 
    print ("Unknown Option Selected!") 

def ADDTOOLS():
  print ("What Else would you like to do?")
  selection = input('''
  [1]="Spit an Episode" 
  [2]="Reduce all Videos in folder Size (.mp4)"
  [3]="Exit"
  ''')

  if selection == '1': 
    SplitEpisode()
  elif selection == '2': 
    VIDEOREDUCER()
  elif selection == '3': 
    end
  else: 
    print("Unknown Option Selected!") 

def DeDup():
  print("Lets start with file de Duplication")
#  .\VDF -i cwd -r -p 96
  Submenu()

def Converter():
  print ("Lets start with file conversions")
#  FOR /F "tokens=*" %%I IN ('DIR /B /S %HBFILETYPES%') do (
  print("File: %FULLFILENAME%")
#  "%HANDBRAKE_CLI%" -i "%FULLFILENAME%" -o "%TEMPFILENAME%" %HBOPTIONS%
#    if not errorlevel 1 (
#    move /Y "%TEMPFILENAME%" "%%~dpnI.mp4"
#    if not errorlevel 1 set /A FilesEncoded+=1
#  )
#    if exist "%TEMPFILENAME%" del "%TEMPFILENAME%"
#    if exist "%%~dpnI.mp4" del "%FULLFILENAME%"
#  )
  Submenu()

def MKV2MP4():
#    FOR /F "tokens=*" %%I IN ('DIR /B /S *.mkv') do (
  print("File: %FULLFILENAME%")
#   "%FFMPG%" -i "%FULLFILENAME%" -c copy "%TEMPFILENAME%" -movflags faststart
#        if not errorlevel 1 (
#            move /Y "%TEMPFILENAME%" "%%~dpnI.mp4"
#            if not errorlevel 1 set /A FilesEncoded+=1
#        )
#        if exist "%TEMPFILENAME%" del "%TEMPFILENAME%"
#        if exist "%%~dpnI.mp4" del "%FULLFILENAME%"
#    )
#
  Submenu()

def Optimizer():
  FilesFound = 0
  FilesEncoded = 0
#  for /F "delims=" %%I in ('dir *.mkv *.mp4 /A-D-H /B /S 2^>nul') do (
#    FullFileName = "%%I"
#    TempFileName = "%%~dpnI_new%%~xI"
#    AudioCodec = ""
#    AudioOption = "ac3"
#    VideoCodec = ""
#    VideoOption = "h264"
#    set /A FilesFound+=1
#
#    for /F "eol={ tokens=1,2 delims=,:[ ]{} " %%B in ('"%FFPROB% %ProbeOptions% "%%I""') do (
#         if "%%~B" == "codec_name" (
#            if not defined VideoCodec (
#                set "VideoCodec=%%~C"
#                if "%%~C" == "h264" set "VideoOption=copy"
#            ) else (
#                set "AudioCodec=%%~C"
#                if "%%~C" == "ac3" set "AudioOption=copy"
#            )
#        )
#    )
#
  print("File: {FullFileName}")
  print("Video codec: {VideoCodec}")
  print("Audio codec: {AudioCodec}")
#    if not "!VideoOption!" == "!AudioOption!" (
#        FFMPG %MpegOptions% -i "!FullFileName!" -c:v !VideoOption! -c:a !AudioOption! "!TempFileName!"
#        if not errorlevel 1 (
#            move /Y "!TempFileName!" "!FullFileName!"
#            if not errorlevel 1 set /A FilesEncoded+=1
#        )
#        if exist "!TempFileName!" del "!TempFileName!"
#    )
#  )

#  if %FilesFound% == 1 (set "PluralS=") else set "PluralS=s"
  print("Re-encoded %FilesEncoded% of %FilesFound% video file%PluralS%.")
  Submenu()

def Filer():
  print("lets put those files where they belong")
#  FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FILEBOT%" -rename "%%G" -script fn:amc --output "%OUTPUT_DIR%" --action move --conflict skip -non-strict --log-file amc.log --def unsorted=n music=y artwork=n clean=y movieFormat="%OUTPUT_DIR%\Movies\{n} ({y})\{n} ({y})" seriesFormat="%OUTPUT_DIR%\TV Shows\{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t.replaceAll(/[`´‘’ʻ]/, /'/).replaceAll(/[!?.]+$/).replacePart(', Part $1')}{'.'+lang}" "ut_label=%L" "ut_state=%S" "ut_title=%N" "ut_kind=%K" "ut_file=%F" "ut_dir=%D"
  Submenu()

def Tester():
  print("Time to list the files with possible playback issues")
#  subprocess.Popen(["powershell", "-executionpolicy bypass -File "print(LibaryCheck)" -dir "print(WORK_DIR)" -threads "print(THREADL)"], stdout=subprocess.PIPE)
  Submenu()

def SplitEpisode():
  print("Lets Split an episode for you")
  print("Lets find this dual episode")
#    SET /P EPISODELOCATION=where is this dual episode located? ex: X:\mine\ here:
#IF "%EPISODELOCATION%"=="" goto Submenu
#SET /P EPISODENAME=what is this dual episode Name? ex: Dual_Episode.mp4 here:
#IF "%EPISODENAME%"=="" goto Submenu
#   print("lets setup the first episode")
#SET /P EPISODEoutput1=what is the first episode Name? ex: Episode1 here:
#IF "%EPISODEoutput1%"=="" SET "EPISODEoutput1=Episode1"
#SET /P STARTTIME1=what is the first episode Start time? ex: 00:00:00 here:
#IF "%STARTTIME1%"=="" SET "STARTTIME1=00:00:00"
#SET /P ENDTIME1=what is the first episode END time? ex: 00:00:00 here:
#IF "%ENDTIME1%"=="" SET "ENDTIME1=00:00:00"
#print Lets setup the Second Episode
#SET /P EPISODEoutput2=what is the Second episode Name? ex: Episode2 here:
#IF "%EPISODEoutput2%"=="" SET "EPISODEoutput1=Episode2"
#SET /P STARTTIME2=what is the Second episode Start time? ex: 00:00:00 If it starts Immediantly after Episode 1 Press Enter here:
#IF "%STARTTIME2%"=="" SET "STARTTIME2=%ENDTIME1%%"
#SET /P ENDTIME2=what is the first episode END time? ex: 00:00:00 here:
#IF "%ENDTIME2%"=="" SET "ENDTIME2=00:30:00"
#print("Splitting off the first Episode")
#%FFMPG% -i "%EPISODELOCATION%%EPISODENAME%" -vcodec copy -acodec copy -ss %STARTTIME1% -t %ENDTIME1% "%EPISODELOCATION%%EPISODEoutput1%.mp4"
#print("Splitting off the Second Episode")
#%FFMPG% -i "%EPISODELOCATION%%EPISODENAME%" -vcodec copy -acodec copy -ss %STARTTIME2% -t %ENDTIME2% "%EPISODELOCATION%%EPISODEOUTPUT2%.mp4"
#submenu()

def VIDEOREDUCER():
  print("lets get Reducing")
# things
# and 
# stuff
  Submenu()


def SplitEpisode():
  print("Lets Reduce some video sizes")
  print("Note do this in a test enviorment first")
#FOR /F "tokens=*" %%I IN ('DIR /B /S *.ts -or *.avi -or *.mov -or *.m4v -or *.flv -or *.MPV -or *.MPEG -or *.WMV -or *.mp4') do (
#    print File: %FULLFILENAME%
#   "%HANDBRAKE_CLI%" -i "%FULLFILENAME%" -o "%TEMPFILENAME%" -E ffaac -B 96k -6 stereo -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all --optimize
#        if not errorlevel 1 (
#            move /Y "%TEMPFILENAME%" "%%~dpnI.mp4""
#            if not errorlevel 1 set /A FilesEncoded+=1
#        )
#        if exist "%TEMPFILENAME%" del "%TEMPFILENAME%"
#        if exist "%%~dpnI.mp4" del "%FULLFILENAME%"
#    )
#)
  Submenu()


def Automagic():
  print("Lets start with file de Duplication")
#%VDF% -i %WORK_DIR% -r -p 96
  print("Automagiclly starting")
  print("Lets start with file conversions")
#FOR /F "tokens=*" %%I IN ('DIR /B /S %HBFILETYPES%') do (
#    setlocal EnableDelayedExpansion
#    print(
#    print File: %FULLFILENAME%
#   "%HANDBRAKE_CLI%" -i "%FULLFILENAME%" -o "%TEMPFILENAME%" %HBOPTIONS%
#        if not errorlevel 1 (
#            move /Y "%TEMPFILENAME%" "%%~dpnI.mp4""
#            if not errorlevel 1 set /A FilesEncoded+=1
#        )
#        if exist "%TEMPFILENAME%" del "%TEMPFILENAME%"
#        if exist "%%~dpnI.mp4" del "%FULLFILENAME%"
#    )
#)
#
#if %FilesFound% == 1 (set "PluralS=") else set "PluralS=s"
#print
#print Re-encoded %FilesEncoded% of %FilesFound% video file%PluralS%.
#print N | FOR /F "tokens=*" %%G IN ('DIR /B /S *.mkv') DO "%FFMPG%" -i "%%G" -c copy "%OUTPUT_DIR%\%%~nG.mp4" -movflags faststart
#setlocal EnableExtensions DisableDelayedExpansion
#set "FilesFound=0"
#set "FilesEncoded=0"
#
#for /F "delims=" %%I in ('dir *.mp4 /A-D-H /B /S 2^>nul') do (
#
#    for /F "eol={ tokens=1,2 delims=,:[ ]{} " %%B in ('%FFPROB% %ProbeOptions% %%I') do (
#        if "%%~B" == "codec_name" (
#            if not defined VideoCodec (
#                set "VideoCodec=%%~C"
#                if "%%~C" == "h264" set "VideoOption=copy"
#            ) else (
#                set "AudioCodec=%%~C"
#                if "%%~C" == "ac3" set "AudioOption=copy"
#           )
#        )
#    )
#    print(
#    print File: %FullFileName%
#    print Video codec: %VideoCodec%
#    print Audio codec: %AudioCodec%
#    if not "%VideoOption%" == "%AudioOption%" (
#        "%FFMPG%" %MpegOptions% -i "%FullFileName%" -movflags faststart -c:v %VideoOption% -c:a %AudioOption% "%TempFileName%"
#        if not errorlevel 1 (
#            move /Y "%TempFileName%" "%FullFileName%"
#            if not errorlevel 1 set /A FilesEncoded+=1
#        )
#        if exist "%TempFileName%" del "%TempFileName%"
#    )
#)
#
#if %FilesFound% == 1 (set "PluralS=") else set "PluralS=s"
#print ("Re-encoded %FilesEncoded% of %FilesFound% video file%PluralS%.")
#print ("lets put those files where they belong")
#FOR /F "tokens=*" %%G IN ('DIR /B /S *.mp4') DO "%FILEBOT%" -rename "%%G" -script fn:amc --output "%OUTPUT_DIR%" --action move --conflict skip -non-strict --log-file amc.log --def unsorted=n music=y artwork=n clean=y movieFormat="%OUTPUT_DIR%\Movies\{n} ({y})\{n} ({y})" seriesFormat="%OUTPUT_DIR%\TV Shows\{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t.replaceAll(/[`´‘’ʻ]/, /'/).replaceAll(/[!?.]+$/).replacePart(', Part $1')}{'.'+lang}" "ut_label=%L" "ut_state=%S" "ut_title=%N" "ut_kind=%K" "ut_file=%F" "ut_dir=%D"
#print ("Time to list the files with possible playback issues")
#Powershell.exe -executionpolicy bypass -File "%LIBARYCHECK%" -dir "%WORK_DIR%" -threads "%THREADL%"
  Submenu()

def DISTRIBUTED_MAGIC():
# future magic
  Submenu()

# ------------------------------------------------------------------------------------------------------------------------
# Now with everything defined lets Start the Program
# ------------------------------------------------------------------------------------------------------------------------
START()