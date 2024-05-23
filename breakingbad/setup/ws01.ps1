#Powershell Script to configure and enroll a workstation to the domain
#change hostname for multiple machines
#do this before user creation to set local admins on machines

Rename-Computer "ws01"
winrm qc -q -force
Set-DNSClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses 172.27.0.200, 172.27.0.2
cmd /c REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "GenerateLLMNR" /t REG_SZ /F /D "C:\AD-Attack-Lab\GenerateLLMNR.exe"
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx\0001\Depend /v "FinishSetup" /d "powershell.exe -noprofile -command Add-Computer -DomainName breakingbad.abq -Restart"
#Add-Computer -DomainName breakingbad.abq -Restart



