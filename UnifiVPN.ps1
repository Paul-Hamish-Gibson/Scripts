##Unifi VPN Setup##

#install module
Set-PSRepository -Name "psgallery" -InstallationPolicy "Trusted"
install-module -name VPNCredentialsHelper -confirm:$false

#get data
"Please Enter the Name of the Connection"
$Name = Read-Host
"Please Enter the VPN server address (xxx.xxx.xxx.xxx)"
$IP = Read-Host
"please Enter the Security Key"
$key = Read-Host
"Please enter the Username"
$user = Read-Host
"Please Enter the Password"
$Pass = Read-host -AsSecureString

#create vpn
Add-VpnConnection -name $name -ServerAddress $IP -RememberCredential -AuthenticationMethod "MSChapv2" -EncryptionLevel "Optional" -TunnelType "l2tp" -L2tpPsk $key -Force -PassThru -confirm:$false
Set-VpnConnectionUsernamePassword -connectionname $Name -username $user -password $Pass

#optional Registry Key
#REG ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f

#to keep page up and review
Get-VpnConnection -name $name
