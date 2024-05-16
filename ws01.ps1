#Powershell Script to configure and enroll a workstation to the domain
#change hostname for multiple machines
#do this before user creation to set local admins on machines

Rename-Computer "ws-01"
Set-DNSClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses 172.27.0.200, 172.27.0.2
#need to restart here?
Add-Computer -DomainName breakingbad.abq -Restart
