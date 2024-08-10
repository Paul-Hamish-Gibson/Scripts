#Goal here is to automate new PCs
#paulg 5/9/23

#Software Deployments should happen automatically through ninja based on policy
##Winget
$winget_installed = Get-AppxPackage -name "Microsoft.DesktopAppInstaller"

if(!($winget_installed)){
    $progressPreference = 'silentlyContinue'
    $latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
    $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
    Write-Information "Downloading winget to artifacts directory..."
    Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
    Add-AppxPackage $latestWingetMsixBundle
}

##Powershell 7
winget install "Microsoft.Powershell" --accept-package-agreements

##Adobe Reader
winget install 'Adobe.Acrobat.Reader.64-bit' --accept-package-agreements

##Chrome
winget install "Google.Chrome" --accept-package-agreements

##set date-time
$time_zone = get-timezone
if($time_zone != "US Eastern Standard Time")
{
    set-timezone "US Eastern Standard Time"
}

##set power plan to not sleep
Powercfg /Change standby-timeout-ac 0
Powercfg /Change monitor-time-ac 60
Powercfg /Change hibernate-timeout-ac 0

##Lenovo Commercial Vantage

$list = winget list
for($i = 0; $i -le $list.length; $i++){
    $item = $list[$i]
    if($item.Contains("*Vantage*"){
        winget uninstall "Lenovo Vantage Service"
        Break
    }
}

winget install "Lenovo Commercial Vantage" --accept-package-agreements

start-sleep -seconds 15

#Install Lenovo System Update Admin Tools update things
$lenovo_url = 'https://download.lenovo.com/pccbbs/thinkvantage_en/zb59_tvsu_win7_win8_admin110.exe'

mkdir C:\allevia
mkdir C:\allevia\temp
$path = 'C:\allevia\temp'

invoke-webrequest -uri $lenovo_url -OutFile "$path\LenovoUpdateInstaller.exe"

start-process -filepath "$path\LenovoUpdateInstaller.exe" -argumentList "/VERYSILENT /NORESTART /DIR=C:\tvsu\temp"

Start-process "C:\'Program Files (x86)'\Lenovo\'System Update'\tvsu.exe" -ArgumentList "/CM -search A"