Rename-Computer "DC1"
New-NetIPAddress -IPAddress 172.27.0.200 -DefaultGateway 172.27.0.2 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex
Set-DNSClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses 172.27.0.200, 172.27.0.2
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Restart-Computer
