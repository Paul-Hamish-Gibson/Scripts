##VPN Setup##

#install Nu-get
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope Currentuser -confirm:$false

#install module to add credentials to a VPN
#if(!(get-module -name VPNCredentialsHelper)){
Set-PSRepository -Name "psgallery" -InstallationPolicy "Trusted"
install-module -name VPNCredentialsHelper -confirm:$false -Force -scope currentuser -AllowClobber -ErrorAction SilentlyContinue
#}

#allowing unsigned scripts, this allows the credential helper module to function, and will fail to add credentials otherwise
Set-ExecutionPolicy unrestricted -scope currentuser -force -confirm:$false

#get data
"This a Unifi Connection? (Answer false for Meraki)"
$unifi = read-host -prompt "$true or $false"
try {
$unifi = [system.Convert]::ToBoolean($unifi)
}Catch {
    Write-host "Sorry, please answer 'True' for Unifi or 'False' for Meraki."
    $unifi = read-host -Prompt "Unifi? $true or $False"
    $unifi = [system.Convert]::ToBoolean($unifi)
}
"What would you like to name of the connection?"
$Name = Read-Host
"Please Enter the VPN server address (xxx.xxx.xxx.xxx) or site"
$IP = Read-Host
"please Enter the Security Key/Shared Secret"
$key = Read-Host
"Please enter the Username"
$user = Read-Host
"Please Enter the Password"
$Pass = Read-host

#create vpn
if ($Unifi){
Add-VpnConnection -name $name -ServerAddress $IP -RememberCredential -AuthenticationMethod "MSChapv2" -EncryptionLevel "Optional" -TunnelType "l2tp" -L2tpPsk $key -Force -confirm:$false

#optional Registry Key
#REG ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f
}

else {
    #Creates Meraki VPN
    Add-VpnConnection -name $name -ServerAddress $IP -RememberCredential -AuthenticationMethod "PAP" -TunnelType "l2tp" -L2tpPsk $key -Force -confirm:$false -ErrorAction SilentlyContinue
}

#add credenials
Set-VpnConnectionUsernamePassword -connectionname $Name -username $user -password $Pass

#to keep page up and review
Get-VpnConnection -name $name
write-host "Your VPN is Setup!" -ForegroundColor Cyan -BackgroundColor Yellow
"would you like to connect to the vpn now? [y] or [n]"
$cnct = read-host
if ($cnct -eq "y"){
    start-sleep -Seconds 3
     rasdial $Name $user.ToString() $Pass.ToString()
 }else {exit}