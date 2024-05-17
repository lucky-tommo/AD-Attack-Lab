param( 
    [Parameter(Mandatory=$true)] $JSONFile,
    [switch]$Undo
 )

function CreateADGroup(){
    param( [Parameter(Mandatory=$true)] $groupObject )

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
}

function AddAdminGroup(){
    param( [Parameter(Mandatory=$true)] $domainadmingroupsObject )

    $name = $domainadmingroupsObject.name
    Add-ADGroupMember -Identity "Domain Admins" -Members $name
  
}

function RemoveADGroup(){
    param( [Parameter(Mandatory=$true)] $groupObject )

    $name = $groupObject.name
    Remove-ADGroup -Identity $name -Confirm:$False
}


function CreateADUser(){
    param( [Parameter(Mandatory=$true)] $userObject )

    # Pull out the name from the JSON object
    $name = $userObject.name
    $password = $userObject.password

    # Generate a "first initial, last name" structure for username
    #$firstname, $lastname = $name.Split(" ")
    #$username = ($firstname[0] + $lastname).ToLower()
    #$samAccountName = $username
    #$principalname = $username

    #Generate a "first name, last name" structure for username - user adm.firstname for admin accounts in JSON file. 
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname + "." + $lastname).ToLower()
    $samAccountName = $username
    $principalname = $username
    
    # Actually create the AD user object
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    # Add the user to its appropriate group
    foreach($group_name in $userObject.groups) {

        try {
            Get-ADGroup -Identity "$group_name"
            Add-ADGroupMember -Identity $group_name -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning "User $name NOT added to group $group_name because it does not exist"
        }
    }
    
    # Add to local admin as needed
    # if ( $userObject.local_admin -eq $True){
    #     net localgroup administrators $Global:Domain\$username /add
    # }
    $add_command="net localgroup administrators $Global:Domain\$username /add"
    foreach ($hostname in $userObject.local_admin){
        echo "Invoke-Command -Computer $hostname -ScriptBlock { $add_command }" | Invoke-Expression
    }
}

function RemoveADUser(){
    param( [Parameter(Mandatory=$true)] $userObject )

    $name = $userObject.name
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname + "." + $lastname).ToLower()
    $samAccountName = $username
    Remove-ADUser -Identity $samAccountName -Confirm:$False
}
function AD-AddACL {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]$Destination,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [System.Security.Principal.IdentityReference]$Source,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]$Rights

        )
        $ADObject = [ADSI]("LDAP://" + $Destination)
        $identity = $Source
        $adRights = [System.DirectoryServices.ActiveDirectoryRights]$Rights
        $type = [System.Security.AccessControl.AccessControlType] "Allow"
        $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
        $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $identity,$adRights,$type,$inheritanceType
        $ADObject.psbase.ObjectSecurity.AddAccessRule($ACE)
        $ADObject.psbase.commitchanges()
}
function badAcls {
#ACL for Cartel to control DEA
        Write-Good "Adding misconfigured ACL rule for the $Global:Cartel group."	
        $DestinationGroup = Get-ADGroup -Identity $Global:Cartel
        $SourceGroup = Get-ADGroup -Identity $Global:DEA
        AD-AddACL -Source $DestinationGroup.sid -Destination $SourceGroup.DistinguishedName -Rights "GenericAll"
        Write-Info "Whoops! GenericAll rights granted to $Global:Cartel."
#ACL for Todd to control Jesse  (remember the hole?)       
        Write-Good "Adding misconfigured ACL rule for Todd Alquist to Jesse Pinkman."
        $vulnAclUser = Get-ADUser -Identity "todd.alquist"
        $SourceUser = Get-ADUser -Identity "jesse.pinkman"
        AD-AddACL -Source $vulnAclUser.sid -Destination $SourceUser.DistinguishedName -Rights "GenericAll"
        Write-Info "Whoops! GenericAll rights granted to Todd Alquist to Jesse Pinkman."
#ACL for Todd to control Jesse (Admin)
        Write-Good "Adding misconfigured ACL rule for Todd Alquist to Jesse Pinkman (admin)."
        $vulnAclUser = Get-ADUser -Identity "todd.alquist"
        $SourceUser = Get-ADUser -Identity "adm.jesse.pinkman"
        AD-AddACL -Source $vulnAclUser.sid -Destination $SourceUser.DistinguishedName -Rights "GenericAll"
        Write-Info "Whoops! GenericAll rights granted to Todd Alquist to Jesse Pinkman(admin)."
#ACL for Helpdesk to control IT Admin        
        Write-Good "Adding misconfigured ACL rule for the $Global:Helpdesk."	
        $DestinationGroup = Get-ADGroup -Identity $Global:Helpdesk
        $SourceGroup = Get-ADGroup -Identity $Global:IT Admin
        AD-AddACL -Source $DestinationGroup.sid -Destination $SourceGroup.DistinguishedName -Rights "GenericAll"
        Write-Info "Whoops! GenericAll rights granted to $Global:Helpdesk."

}	
function BadConfig(){
#Disable SMB Signing
    Set-SmbClientConfiguration -RequireSecuritySignature 0 -EnableSecuritySignature 0 -Confirm -Force
#Kerberoasting
    setspn -s iamtheonewhoknocks/iamthedanger adm.walter.white
#ASREP Roasting
    Set-ADAccountControl -Identity saul.goodman -DoesNotRequirePreAuth 1
    
function WeakenPasswordPolicy(){
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}

function StrengthenPasswordPolicy(){
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 0", "PasswordComplexity = 1").replace("MinimumPasswordLength = 1", "MinimumPasswordLength = 7") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}


$json = ( Get-Content $JSONFile | ConvertFrom-JSON)
$Global:Domain = $json.domain

if ( -not $Undo) {
    WeakenPasswordPolicy
    
    
    foreach ( $group in $json.groups ){
        CreateADGroup $group
    }
    
    foreach ( $group in $json.domainadmingroups ){
        AddAdminGroup $group
    }
    
    
    foreach ( $user in $json.users ){
        CreateADUser $user
    }
    
}
else{
    StrengthenPasswordPolicy

    foreach ( $user in $json.users ){
        RemoveADUser $user
    }
    foreach ( $group in $json.groups ){
        RemoveADGroup $group
    }
    
}

