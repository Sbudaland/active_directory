
param([Parameter(Mandatory=$true)] $OutputJSONFile)

$group_names = [System.Collections.ArrayList](Get-Content "data/group_names.txt")
$passwords = [System.Collections.ArrayList](Get-Content "data/passwords.txt")
$names = [System.Collections.ArrayList](Get-Content "data/names.txt")

$groups = @()
$users = @()

$num_groups = 10
for($i = 0; $i -lt $num_groups; $i++){
    $group_name = (Get-Random -InputObject $group_names)
    $group = @{"name" = "$group_name"}
    $groups += $group
    $group_names.Remove($group_name)
}


$num_users = 100
for($i = 0; $i -lt $num_users; $i++){
    $user = (Get-Random -InputObject $names)
    $password = (Get-Random -InputObject $passwords)
    $new_user = @{
        "name"="$user"
        "password"="$password"
        "groups"= @((Get-Random -InputObject $groups).name )
    }
    $users += $new_user

    $names.Remove($user)
    $passwords.Remove($password)
}

@{
    "domain"="xyz.com"
    "groups"=$groups
    "users"=$users
} | ConvertTo-Json | Out-File $OutputJSONFile



