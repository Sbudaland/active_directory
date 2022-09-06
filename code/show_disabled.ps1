param([Parameter(Mandatory=$true)] $JSONFile)


$json = (Get-Content $JSONFile | ConvertFrom-JSON)


foreach($name in $json.SamAccountName){
    echo $name
}