#!pwsh
#win11Check_v1.6
# Check if a Windows 10 device is compatible with Windows 11
# Then store that data into a Custom Field in NinjaOne
# The reason for failure will be printed to host (viewable in NinjaOne Activities)

# PaulG
# 8/5/2024

#Start Script

#Pull in values from NinjaOne
$preApproved = ninja-property-get Win11Upgrade
write-host "Win11Ugrade Field is $($preApproved)"

#declare vars for System requirements

$reqWindowsVersion = 10
$reqWindowsArch = "64-bit"
$reqDiskSize = 64
$reqRamSize = 4
$reqProcessorSpeed = 1000
$reqProcessorCores = 2
#$reqTpmStatus = $true
#$reqTpmVersion = 2.0
$reqFirmware = "UEFI"

#declare variables for meeting each requirement

$meetsWindowsVersion = $false
$meetsWindowsArch = $false
$meetsDiskSize = $false
$meetsRamSize = $false
$meetsProcessorSpeed = $false
$meetsProcessorCores = $false
$meetsTpmStatus = $false
$meetsTpmVersion = $false
$meetsFirmware = $false
$SSD = $false
$cpuAge = $false
$motherboard = Get-WmiObject Win32_BaseBoard
$motherboard = "$($motherboard.Manufacturer) $($motherboard.Product)"
$tpmMobos = $false

#create log file
$log = 'c:\allevia\logs\win11check_log.txt'
$logExists = test-path $log
if (!($logExists)){

    new-item -path c:\allevia\logs -ItemType file -Name win11check_log.txt -force
    Write-Output "Log File created $(get-date)" >$log
}else {
    Write-Output "`nScript Start $(get-date)`n`n">>$log
}

Write-Host "Start of Script: Win11Check Version 1.4`n"

#Evaluate Windows Archetecture
$osInfo = $(get-cimInstance Win32_OperatingSystem)

if ($osinfo.OSArchitecture -like $reqWindowsArch ) {
    $meetsWindowsArch = $true
    write-host "OS Architecture is 64-bit"
}else{
    
    write-host "Does not meet Architecture requirements." 
}

#Evaluate Windows Version
if ( $osInfo.Name -like "*$reqWindowsVersion*"){
    $meetsWindowsVersion = $true
    write-host "Version is Windows 10"
}else{
    write-host "Does not meet Version requirements." 
}


#Evaluate SSD or Magnetic Spinning Disk Dinosaur HDD

$disk = get-physicaldisk | Where-Object { $_.deviceID -eq 0 }
if ($disk.MediaType -like "SSD"){
    $SSD = $true
    Write-host "OS drive is an $($disk.MediaType)`n"
}else{
    write-host "$($disk.MediaType) doesn't meet SSD Requirement`n"
}

#Evaluate Required Disk Size

$bootDisk = $(Get-Disk | Where-Object {$_.IsBoot -eq "True"})
$diskSize = $bootDisk.Size/1GB

if ( $diskSize -ge $reqDiskSize){
    $meetsDiskSize = $true
    write-host "$($diskSize) of Disk Size is larger than required $($reqDiskSize)`n"
}else{
    write-host "Does not meet Disk Size requirements." 
}


#Evaluate RAM Size
$ramSize = (Get-CimInstance Cim_PhysicalMemory | measure-object -property Capacity -Sum).sum/1GB

if ($ramSize -ge $reqRamSize){
    $meetsRamSize = $true
    write-host "$($ramSize) of RAM is larger than required $($reqRamSize)`n"
}else{
    write-host "Does not meet RAM requirements." 
}

#Evaluate Processor Speed

$processorInfo = get-cimInstance Win32_Processor
$processorSpeed = $processorInfo.MaxClockSpeed

if ( $processorSpeed -ge $reqProcessorSpeed){
    $meetsProcessorSpeed = $true
    write-host "CPU Speed of $($processorSpeed) is greater than required $($reqProcessorSpeed)`n"
}else{
    Write-Host "Does not meet Processor Speed requirements."
}

#Evaluate Processor Age

#Import reference table
invoke-webrequest 'https://raw.githubusercontent.com/Allevia-Technology/PublicData/main/ProcessorRefTable.csv' -outfile "C:\allevia\logs\ReferenceTable.csv"
$refTable = import-csv -path "C:\allevia\logs\ReferenceTable.csv"
#get installed CPU
$processor = get-wmiobject win32_processor
$processorName = $processor.name.trim()
#get current date (year)
$today = Get-Date
$thisYear = $today.year
#initialize age variable to modify if there's a match
$age = $null

#try to get age from github table
ForEach($row in $refTable) {
    if ($row.CPUNames -contains $processorName) {
        $release = $row.ReleaseDates
        $releaseYear = $release[3] + $release[4] + $release[5] + $release[6]
        $age = $thisYear - $releaseYear
        [int]$releaseInt = [convert]::ToInt32($release[1], 10)
        if($releaseInt -le 2){
            $age = $age + 1
        }
        break
    }
}
if($null -like $age){
    write-host "CPU ($($processorName)) not in the list of CPUs on Github`n"
}

#Evaluate if CPU is in a reasonable age range
if($null -notlike $age -and $age -le 7){
    $cpuAge = $true
    write-host "CPU $($processorName) is $($age) year(s) old"
}elseif($null -notlike $age -and $age -gt 7){
    $cpuAge = $false
    write-host "CPU age:$($age), doesn't not meet minimum age requirement"
}

#Evaluate Processor Cores
$processorCores = $processorInfo.NumberOfCores

if ($processorCores -ge $reqProcessorCores) {
    $meetsProcessorCores = $true
    write-host "CPU Cores ($($processorCores)) is greater than required $($reqProcessorCores)"
}else{
    write-host "Does not meet Processor Core requirements." 
}
#Evaluate Firmware Type
if ($env:firmware_type -like $reqFirmware){
    $meetsFirmware = $true
    write-host "firmware type is $($env:firmware_type)"
}else{
    write-host "Does not meet Firmware requirements." 
}

#Evaluate TPM Status

$enabledTPM = Get-Tpm
if ($enabledTPM.TpmPresent -like "True" -and $enabledTPM.TpmEnabled -like "True") {
    $meetsTpmStatus = $true
    $tpmMobos = $true
}elseif($enabledTPM.TpmPresent -like "False" -and $enabledTPM.TpmEnabled -like "False"){
    write-host "Does not meet TPM Status requirements." 
    Write-Output $enabledTPM.TpmPresent >> $log
}elseif($enabledTPM.TpmPresent -like "True" -and $enabledTPM.TpmEnabled -like "False"){
    Enable-TpmAutoProvisioning -verbose >> $log
    write-host "TPM Present but not enabled`nAttempted to enabled TPM (check $($log))"
}

#Evaluate TPM Version
if($meetsTpmStatus -like $true){
    $tpmData = ((tpmtool.exe getdeviceinformation) -split "`n")[2]
    if($tpmData -like "*2.*"){
        $meetsTpmVersion = $true
        write-host "TPM is $($tpmData)"
    }else{
        write-host "Does not meet TPM Version requirements."
    }
}else{
    $meetsTpmVersion = $null
}
#Evaluate Motherboard thoroughly for compatibilty
#get list of motherboards from Ninja that are able to have a TPM installed or enabled.

if(!($meetsTpmStatus)){
    invoke-webrequest 'https://raw.githubusercontent.com/Allevia-Technology/PublicData/main/ApprovedMobos.csv' -outfile "C:\allevia\logs\ApprovedMobos.csv"
    $knownMoBosCsv = import-csv -path "C:\allevia\logs\ApprovedMobos.csv"
    $knownMoBos = $knownMoBosCsv.Model
    Write-host "Checking Motherboard for approved list section" 
    if($null -like $knownMoBos){
        write-host "no existing data for motherboards detected"
    }else{
        foreach ($knownMoBo in $knownMoBos){
            if ($knownMoBo -like $motherboard){
                write-output "Motherboard matches list of upgradable motherboards" >> $log
                Write-Host "$($motherboard) is on the list of Motherboards"
                $tpmMobos = $true
            }else{
                write-host "$($motherboard) isn't in the known motherboards CSV file in github"
            }   
        }
    }
}

#Assess tpm and mobo status
$tpmSituation = $false
if($meetsTpmVersion -like $null){
    if ($meetsTpmStatus -or $tpmMobos){
        $tpmSituation = $true
    }
}elseif($meetsTpmVersion -like $true){
    if ($meetsTpmStatus -or $tpmMobos){
        $tpmSituation = $true
    }
}
$addTpm = $false
if($meetsTpmStatus -like $false -and $tpmMobos -like $true){
    $addTpm = $true
}
write-host "TPM Situations is marked as $($tpmSituation)"
#Compile Required Variables to Evaluate

if ($meetsWindowsVersion -and $meetsWindowsArch -and $meetsDiskSize -and $meetsRamSize -and $meetsProcessorSpeed -and $meetsProcessorCores -and $tpmSituation -and $meetsFirmware -and $SSD -and $cpuAge){
    add-content -Path $log -Value "Seems Upgradable"
    write-host "setting to Upgradable.`n`n"
    Ninja-property-set Win10ReplaceOrUpgrade "Upgrade"
}elseif($null -like $cpuAge){
    Ninja-Property-Set Win10ReplaceOrUpgrade "Check CPU"
    write-host "Check Cpu`n`n"
}elseif($meetsWindowsVersion -and $meetsWindowsArch -and $meetsDiskSize -and $meetsRamSize -and $meetsProcessorSpeed -and $meetsProcessorCores -and $tpmSituation -and $meetsFirmware -and $cpuAge){
    Ninja-Property-Set Win10ReplaceOrUpgrade "Upgradable but HDD"
    write-host "Change Drive to SSD`n`n"
}elseif($meetsWindowsVersion -and $meetsWindowsArch -and $meetsDiskSize -and $meetsRamSize -and $meetsProcessorSpeed -and $meetsProcessorCores -and $tpmSituation -and $meetsFirmware -and $SSD){
    Ninja-Property-Set Win10ReplaceOrUpgrade "Replace: Age"
    write-host "CPU age is too old to reccomend upgrading"
}elseif($meetsWindowsVersion -and $meetsWindowsArch -and $meetsDiskSize -and $meetsRamSize -and $meetsProcessorSpeed -and $meetsProcessorCores -and $tpmSituation -and $meetsFirmware -and $SSD -and $cpuAge -and $addTpm){
    Ninja-Property-Set Win10ReplaceOrUpgrade "Upgrade add TPM"
    write-host "Needs a TPM Chip, but otherwise can be upgraded"
}else{
    write-host "setting to Replace.`n`n"
    Ninja-property-set Win10ReplaceOrUpgrade "Replace"
}

$msg = @"
Meets Windows Version: $($meetsWindowsVersion)
Meets Windows Architech: $($meetsWindowsArch)
Meets Disk size: $($meetsDiskSize)
Meets RAM size: $($meetsRamSize)
Meets CPU Speed: $($meetsProcessorSpeed)
meets Number of CPU Cores: $($meetsProcessorCores)
Meets TPM Status: $($meetsTpmStatus)
Meets TPM Version: $($meetsTpmVersion)
Meets Firmware: $($meetsFirmware)
Meets CPU Age: $($cpuAge)
Is an SSD: $($SSD)
$($motherboard) good: $($tpmMobos)
"@

Remove-Item -path "C:\allevia\logs\ReferenceTable.csv"
Write-host $msg
Ninja-property-set windows11upgradeDetails $msg
write-host "End of Script"
#End Script