param([Parameter(Mandatory=$true)] $JSONFile,
                [switch]$Undo
            )

function CreateADGroup(){
    param([Parameter(Mandatory=$true)] $groupObject)
    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
}

function RemoveADGroup(){
    param([Parameter(Mandatory=$true)] $groupObject)
    $name = $groupObject.name
    Remove-ADGroup -Identity $name -confirm:$false
}


function CreateADUser(){
    param([Parameter(Mandatory=$true)] $userObject)

    #Pull out the name from the JSON object
    $name = $userObject.name
    $password = $userObject.password

    #Generate a "first initial, lastname" structure for username
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()
    $SamAccountName = $username
    $principalname = $username
    #Enable-ADAccount -Identity $username
    #Create the AD user object
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    # Add user to the appropriate group
    foreach( $group_name in $userObject.groups){

        try {
            Get-ADGroup -Identity "$group_name"
            Add-ADGroupMember -Identity $group_name -Members $username

        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning "User $name Not added to group $group_name because it does not exist"
        }
    }
}

function RemoveADUser(){
    param([Parameter(Mandatory=$true)] $userObject)
    $name = $userObject.name
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()
    $SamAcountName = $username
    Remove-ADUser -Identity $SamAcountName -Confirm:$false
}


function WeakenPasswordPolicy(){
    secedit /export /cfg c:\Windows\Tasks\secpol.cfg
    (Get-Content c:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File c:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force c:\Windows\Tasks\secpol.cfg -confirm:$false
}

function StrengthenPasswordPolicy(){
    secedit /export /cfg c:\Windows\Tasks\secpol.cfg
    (Get-Content c:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 0", "PasswordComplexity = 1").replace("MinimumPasswordLength = 1", "MinimumPasswordLength = 7") | Out-File c:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force c:\Windows\Tasks\secpol.cfg -confirm:$false
}


$json = (Get-Content $JSONFile | ConvertFrom-JSON)
$Global:Domain = $json.domain



if(-not $Undo){
    WeakenPasswordPolicy
    foreach($group in $json.groups){
        CreateADGroup $group
    }
    foreach($user in $json.users){
        
        CreateADUser $user
    }

}else{
    StrengthenPasswordPolicy
    
    foreach($user in $json.users){
        
        RemoveADUser $user
    }
    foreach($group in $json.groups){
        RemoveADGroup $group
    }

}
