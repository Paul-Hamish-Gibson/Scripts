###Script to pull CPU model and gen, RAM total and Utility, GPU model and Utility, Hard Drive Size and batteryHealthPercent
###Populates data into 'Procurement Info' custom field in Ninja
#Allevia Technology
#SamV
#v1.0 Initial Version created for ThomasM
#v1.1 Added External Monitor Information, populates separate custom field from WMIMontior objects
#v1.2 Split up return object to individual fields for ninja 5.4 release. 
#v1.3 Added RAM speed and slots used to display field
# *** LIVE ***

#grab system information for later queries
$sysInfo = systeminfo

##Find CPU model and generation
$Processor = (get-wmiObject -class win32_processor *)
#Information in same line
$CPUName = $processor.Name

##Find RAM Total and Utilization
$TotalRAM = (($sysInfo[24] -replace '[a-zA-Z,:, ]','')/1000)  
$AvailableRAM = (($sysInfo[25] -replace '[a-zA-Z,:, ]','')/1000)
$RamUtil = $([math]::Round(((($TotalRAM - $AvailableRAM)/$TotalRAM)*100),2))
#Additional RAM Info
$RAM = get-wmiobject win32_physicalMemory
$RAMSpeed = $RAM[0].speed
$RAMUsed = $RAM.length
$MemArray = get-wmiobject win32_physicalMemoryArray
$MaxRAM = $memArray.memorydevices

##GPU Model and Utilization
$GpuMemTotal = (((Get-Counter "\GPU Process Memory(*)\Local Usage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum
$gpu = Get-WmiObject win32_VideoController 

$gpuVRAMs = Get-WmiObject Win32_VideoController | select name, AdapterRAM,@{Expression={$_.adapterram/1GB};label="GB"}  

$sortedGPU = $gpuVRAMs | sort-Object -property GB -Descending

$gpuVRAM = [math]::round($sortedGPU[0].GB)
$gpuName = $sortedGPU[0].name

#Hard Drive size and Type
$drive = get-Volume C
$hdSize = ([int]($drive.size /1GB))
$drive = get-disk 0
$name = $drive.FriendlyName

#Build Format for multi-line custom field
$display = @"
CPU: $CPUName
Total RAM: $TotalRAM GB
RAM Utilization: $RamUtil%
RAM Speed: $RAMSpeed MHz
Slots Used: $RAMUsed of $MaxRAM
Graphics Card: $gpuName
VRAM: $gpuVRAM GB
Total GPU Process Memory Local Usage: $([math]::Round($GpuMemTotal/1GB,2)) GB
Friendly Hard Drive Name: $name
Total Hard Drive Size: $hdSize GB
"@

Ninja-Property-Set cpu $CPUName
Ninja-Property-Set ram "$TotalRam GB"
Ninja-Property-Set ramUtilization "$RamUtil%"
Ninja-Property-Set graphicsCard $gpuName
Ninja-Property-Set vram "$gpuVRAM GB"
Ninja-Property-Set gpuUtilization "$([math]::Round($GpuMemTotal/1GB,2)) GB"
Ninja-Property-Set hardDrive "$name"
Ninja-Property-Set HardDriveSize "$hdSize GB"
Ninja-Property-Set procurementInfo $display


# Ninja-Property-Get cpu $CPUName
# Ninja-Property-Get ram "$TotalRam GB"
# Ninja-Property-get ramUtilization "$RamUtil%"
# Ninja-Property-get graphicsCard $gpuName
# Ninja-Property-get vram "$gpuVRAM GB"
# Ninja-Property-get gpuUtilization "$([math]::Round($GpuMemTotal/1GB,2)) GB"
# Ninja-Property-get hardDrive "$name"
# Ninja-Property-get HardDriveSize "$hdSize GB"
# Ninja-property-get procurementinfo

#External Monitor Information
$Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
$MonitorInfo = ''

ForEach ($Monitor in $Monitors)
{
    $Manufacturer = ($Monitor.ManufacturerName -ne 0 | ForEach{[char]$_}) -join ""
    $MonitorName = ($Monitor.UserFriendlyName -ne 0 | ForEach{[char]$_}) -join ""
    $Serial = ($Monitor.SerialNumberID -ne 0 | ForEach{[char]$_}) -join ""
  
  $MonitorInfo += "$Manufacturer $MonitorName Serial Number: $Serial`r`n"
}
Write-Host "Attached Monitors:"
Write-Host $MonitorInfo.Trim()
$monitorInfo = $monitorInfo.Trim()
Ninja-Property-Set procurementdisplays $MonitorInfo

