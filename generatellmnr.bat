#basic version to have all machines generating LLMNR traffic every X amount of time (configured by timeout) 
:Generate_LLMNR
pushd \\Filesevrer\
timeout /t 30 /nobreak
goto :Generate_LLMNR




#This section below should operate in response to a file - Utilise icons on a share drive - e.g create BackupConfig.json with the icon set as \\anythingnotreal\icon.jpg - upload to share drive - every access of the share drive will trigger LLMNR
#:check_if_exists
#if exist H:\BackupConfig.json goto perform
#timeout /t 30 /nobreak
#:perform
#set this to match the icon - this will simulate users accessing the share drive
#pushd \\anythingnotreal\ 
#goto :check_if_exists 
