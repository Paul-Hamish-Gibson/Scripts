Import-Module ActiveDirectory
Import-Csv "C:\Scripts\Users.csv" | ForEach-Object {
 $samAccountName = $_."samAccountName" 
Get-ADUser -Identity $samAccountName | Disable-ADAccount
}