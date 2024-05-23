LuckyTom's AD attack Lab - Breaking Bad edition

## Repo to create a vulnerable active directory environment with fixed attack paths to demonstrate multiple attack scenarios across different security domains ## 
This is a WIP - YMMV 

Steps to setup
--------------
** you need to have a virtual environment configured and working - my PFSense has two internal zones - 172.27.0.0/24 and 172.27.1.0/24 - if yours differ, change the ip's in the scripts. 

Spin up the machines required
Windows Server 2019 - DC1
Windows Server 2016 - DC2
WS01-03 - Windows 10 or whatever you want. 
Attacker machine - Dealers choice here - Kali,Parrot, whatever. Put it on the internal subnet to simulate a network implant/vpn logged in machine. Put it on other subnet to simulate external attacker. 

1) Once machines are up - get the repo and update it. 
  /setup/GetRepo.bat - This grabs the full repo and unzips it in the current location. 
##WIP - run this every boot to update the repo. 

2) With the Repo present on all machines run:
3) /setup/SetDC1.ps1 on DC1
4) /setup/SetDC2.ps1 on DC2 ##not yet created, need to also install ADCS for petitpotam
5) /setup/SetWS01.ps1 on WS01 <- this sets the ip/hostname/dns, enables WinRM, sets a run key to generate llmnr traffic (WIP), restarts, then joins the domain - use default domain admin creds set on the                                     DC. (administrator:whateveryouset) ##WIP should get this to map a drive from the DC. 
6) /setup/SetWS02.ps1 on WS02
7) /setup/SetWS03.ps1 on WS03
8) /setup/generatedomain.ps1 on DC1 -> feed it schema.json when prompted.
9) Login to ws01 as adm.walter.white, logout, login as skyler.white. #can i automate this?
##Need step here to install CS/Other tools

10) on your kali box - grab the dictionary file from /Attacks/

You're done. 

Attack Avenues in the Lab
--------------------------

User accounts have reasonable password length, but weak complexity for most. You can see the users/passwords in Reference. 
Dictionary file contains the account passwords for demo purposes - use rockyou or something if you want to not crack the passwords. Bruteforce/Rule based won't be a great vector with these passwords. 

Poor user hygiene
-------------------
Low priv. and high priv account using same passwords
-----------------------------------------------------
jesse.pinkman & adm.jesse.pinkman = same password

Domain User with local admin priv
----------------------------------
skyler.white has local admin to ws01

Domain Admin logged into workstation
-------------------------------------
adm.walter.white has logged into ws01

ASREP Roastable users - no krb preauth reqd
----------------------
saul.goodman does not require preauth

SMS Signing disabled
--------------------
DC1 and DC2 do not required SMB Signing
All workstations do not require SMB Signing

Kerberoastable Users
---------------------
adm.walter.white is has an SPN and is kerberoastable

Sketchy ACLs
-------------
Cartel can control DEA - GenericAll
todd.alquist can control jesse.pinkman and adm.jesse.pinkman - GenericAll
Helpdesk can control IT Admin - GenericAll 

Domain Admins
--------------
Group: IT Admin
adm.walter.white
adm.jesse.pinkman
adm.gus.fring








