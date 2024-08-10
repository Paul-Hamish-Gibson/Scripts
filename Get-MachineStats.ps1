## ask for server name, store it in a variable
$server = Read-Host -Prompt "Enter a server name (localhost is default)"

##if no server name is entered, set the variable to localhost
$server = ($server -eq "") ? "localhost" : $server

## gather server stats
$os = Get-CimInstance Win32_OperatingSystem -ComputerName $server
$memTotal = [math]::Round(($os.TotalVisibleMemorySize / 1MB), 2)
$memAvailable = [math]::Round(($os.FreePhysicalMemory / 1MB), 2)

## write stats to host
Write-host "Stats for $server" -ForegroundColor Green
Write-host ('-' * 25)
Write-Host "total Memory        : $memTotal GB"
Write-Host "Available Memory    : $memAvailable GB"
Write-Host "Used Memeory        : $($memTotal - $memAvailable) GB"
Write-Host "Operating System    : $($os.Caption)"
Write-host "System Drive        : $($os.SystemDrive)\"