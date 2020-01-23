# Plexinator
Optimize video files for plex  

Prereqs  
1. Handbreakcli.exe https://handbrake.fr/downloads2.php  
2. ffmpeg.exe https://ffmpeg.org/download.html  
3. filebot.exe https://www.filebot.net/#download  
4. Video files to optimize  
Libary Validator script pulled from: https://github.com/PNRxA/corrupted-media-scanner  
  
Plexinator_Setup_Wizard.bat (Used to set variables and download prereqs)  
Must run Plexinator_Setup_Wizard.bat prior to using Plexinator.bat  

Plexinator.bat (The script that does the stuff)  
Step 1 : Set Working Directory  
Step 2 : HandBreakcli Conversion from ts,m4v,mov,avi,flv,Mpeg to MP4 Web optimised  
Step 3 : FFMPEG to Optimize exhisting .MP4 files (current issue is all .mp4's get optimised even if they dont need it)  
Step 4 : Filebot to rename converted and optimised files  
Step 5 : PNRxA Script utilizing handbreak to test media libary  
  
Feel free to submit issues, commit changes and/or fork and make this better!
