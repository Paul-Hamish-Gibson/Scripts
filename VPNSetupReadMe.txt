
This script will setup either a Unifi or Meraki VPN, it branches at a true or false question near the beginning (answer "true" for Unifi, "false" for Meraki).  From there, it's just copy and paste.  Note, there are some bits of code that were written for Powershell 7.x, that still 5.1 doesn't know what what to do with, but will still execute without errors.


There are a few steps to run this.

1. save the ps1 file to the Desktop or someplace easy to navigate to in powershell

2. Run Powershell as an Admin

3. Run: 

	set-ExecutionPolicy unrestricted
	y

	cd ~\Desktop
	.\VPNSetup.ps1




**after excecution, run:  set-ExecutionPolicy Restricted ***

