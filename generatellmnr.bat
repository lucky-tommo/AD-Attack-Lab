#run at login - does the startup folder still work? 

:check_if_exists
if exist H:\BackupConfig.txt goto perform
timeout /t 30 /nobreak
:perform
pushd \\itsatrap\nothinghere
goto :check_if_exists 
