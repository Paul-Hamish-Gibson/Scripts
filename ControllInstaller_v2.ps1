#this is to automate installation of CW Control by NinjaONe
#Purpose is to automate creation of company/location and install on via schedule
#and replace manual installation

#Allevia Technology
#paulg and samv - 05/02/2023

#IF THE INSTANCE CHANGES, UPDATE VALUE OF $Control_Instance, and then update $URL on line 25 if needed***********
$Control_Instance = "ScreenConnect Client (1a5d6cc5d5f07e3e)"

#check for allevia/temp directory
$path = "c:\allevia\temp"
$path_exists = test-path -path $path
if(!($path_exists)){
    $allevia_dir = test-path -path "c:\allevia\"
    if(!($allevia_dir)){
        mkdir C:\allevia
    }
    mkdir C:\allevia\temp\
}

$log_path = "C:\allevia\logs\"
$log_file = "control_log.txt"

$log_fqfn = "$log_path"+"$log_file"


$log_path_exists = Test-path -path $log_path
if(!($log_path_exists)){
    mkdir "$log_path"
}

$log_file_exists = test-path $log_fqfn
if(!($log_file_exists)){
    new-item -Path $log_path -name $log_file
}

#create function for appending text to the log file just created
function update-log(){
    param
        (
            [Parameter(Mandatory=$true)] [string] $value
        )
    add-content -path $log_fqfn -value $value

}

update-log "Begin Logging - $(get-date)`n Connectwise Control Installer`n`n"
update-log "Directories and log file Exist`nChecking Service...`n"

#Check if Control already installed.  If so, then change Ninja Flag to reflect this, then exit script
$Service = get-service -name $Control_Instance -ErrorAction SilentlyContinue
if($null -ne $Service -and $Service.Status -eq "Running"){
    write-host "`nControl already installed.`n"
    update-log "`nControl already installed.`n"
    set-location C:\ProgramData\NinjaRMMAgent
   .\ninjarmm-cli.exe set cwControlInstalled 1 
   C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set cwControInstallationFailed 0
   exit
}else{
    write-host "`nService not Present`n"
    update-log "`nService not Present`nContinuing with Install`n`n"
}

#IF THE URL UPDATES FOR OUR CONTROL INSTANCE, CHANGE VALUE OF $url TO MATCH.  THIS IS WILL BE THE STRING UP UNTIL THE COMPANY NAME. Note: use single'quotes
update-log "`nCreating URL`n"
#get server url 
$url = 'https://alleviatechnology.hostedrmm.com:8040/Bin/ConnectWiseControl.ClientSetup.msi?h=alleviatechnology.hostedrmm.com&p=8041&k=BgIAAACkAABSU0ExAAgAAAEAAQCLf8ezVTuDeEhWmXnKgK5aHMG5dMBN%2FNHT0knX7xsgDKTuW3IfyHHUpPuZkV9dKdTzEufJjLb1QPhdrNjeZmA7EPxBxeVynskuhVp4KnPUi4BgE6mY8yeI4Yb86kZ9h%2Fi96%2FAvhLuFyvUQHuW37k9P%2BSItt%2FfKfrJqPgVworhtlgxyHSZ0he%2BDjl0GfdvTAwMcg1PbhHAkmMv4bsT6iszfp042RePTey87riFPYnQfh%2BFqMeTpiiVXeaLcZCkqJjJaQ7oxrP8URZwIh%2Fgjf4yWApp0X9fd7f0gjowAgV3K6Ph4f4I%2FgO8GsxLEDiz%2FJ94sgsmLKqCFwwumyml2b%2F2W&e=Access&y=Guest&t=&c='
$url_mid = '&c='
$url_tail = '&c=&c=&c=&c=&c=&c='

#get names from ENV.  These are only accessible if ran as System in NinjaOne
$company = $env:NINJA_ORGANIZATION_NAME
$site = $env:NINJA_LOCATION_NAME

update-log "`n $company`n$site`nModifying to:"

#create complete url for msi

$company_name = [System.Net.WebUtility]::UrlEncode($company)
$company_name = $company_name.replace('+','%20')

$site_name = [System.Net.WebUtility]::UrlEncode($site)
$site_name = $site_name.replace('+','%20')

update-log "`n$company_name at $site_name`n"

$url_full ="$url"+"$company_name"+"$url_mid"+"$site_name"+"$url_tail"
write-host "Full URL at $url_full`n"
update-log "Full URL at $url_full`n"

#download msi to the temp file
update-log "Downloading Installer...`n`n`n"
Invoke-WebRequest -Uri $url_full -OutFile "$path\ConnectWiseControl.ClientSetup.msi" -UseBasicParsing
start-sleep -seconds 10

#run msiexec.exe
$msi = test-path "$path\ConnectWiseControl.ClientSetup.msi"
if ($msi){
    update-log "Installer Successfully Downloaded`nRunning Installer...`n`n"
    write-host "`nInstaller Successfully Downloaded`n"
    msiexec.exe /i "$path\ConnectWiseControl.ClientSetup.msi" /qn
}else{
    write-host "Install failed to download`nAttempting Again`n"
    start-sleep -seconds 10
    get-childitem -path $path | remove-item -force -ErrorAction SilentlyContinue
    Invoke-WebRequest -Uri $url_full -OutFile "$path\ConnectWiseControl.ClientSetup.msi" -UseBasicParsing
    $msi2 = test-path "$path\ConnectWiseControl.ClientSetup.msi"
    if(!($msi2)){
        update-log "download failed`n"
        update-log "$(get-childitem C:\allevia\temp)`n"
        Write-host "Download failed. Exiting Script"
        C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set cwControInstallationFailed 1
        exit
    }else{
        msiexec.exe /i "$path\ConnectWiseControl.ClientSetup.msi" /qn
    }
    
}

#check install
update-log "`nWaiting for application to Start...`n`n`n"
start-sleep -seconds 10
$Service = get-service -name $Control_Instance
update-log "Installer Finished`n$Service`n`n"
if($null -ne $Service -and $Service.Status -eq "Running"){
    update-log "Service is running!"
    write-host "Service is Present and Running"

    #create flag for Custom Field for results
    set-location C:\ProgramData\NinjaRMMAgent
    .\ninjarmm-cli.exe set cwControlInstalled 1
    Write-host "Custom Field Updated"
    remove-item $path\ConnectWiseControl.ClientSetup.msi -force
    C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set cwControInstallationFailed 0

}else{
    #Raise Flag (checkbox) if install fails
    update-log "Install Failed`n"
    write-host "Install Failed"
    C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe set cwControInstallationFailed 1
}