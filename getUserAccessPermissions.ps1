#getUserAcessessPermissions Script
#paulg @ Allevi Technology

#Purpose:  to pull access permissions for a server
#this is for auditing to make sure user access is set as intended
$needsAttention = $false
#create log file
$logFile = "c:\allevia\log\accesspermissions.txt"

if (!(test-connection $logfile)) {
    new-item -path $logFile -force -Value "$(get-date) `n file created `n"
}

#pull shares
$sharedFolders = Get-SmbShare

#check each share for permissions
foreach ($share in $sharedFolders){
    #remove built-in files from loop
    if( $share.name -like '*$'){
        break
    }
    #pull who has access and how much by each share name
    $access = Get-SmbShareAccess -Name $share.Name
    
    #log only files shared to Everyone
    foreach ($accessRight in $access){
        if ($accessRight.AccountName -like "Everyone"){
            add-content -path $logFile -Value "$($acessRight.AccountName) has $($accessRight.AccessRight) to $($share.name)`n" 
            $needsAttention = $true
        }
    }
}