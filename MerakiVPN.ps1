##Meraki VPN Setup##

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
$Pass = Read-host

#create vpn
Add-VpnConnection -name $name -ServerAddress $IP -RememberCredential -AuthenticationMethod "PAP" -TunnelType "l2tp" -L2tpPsk $key -Force -PassThru -confirm:$false
Set-VpnConnectionUsernamePassword -connectionname $Name -username $user -password $Pass