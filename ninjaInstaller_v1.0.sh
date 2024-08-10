#!/bin/bash

#NinjaOne Installer v1.0
#20 May 2024
#PaulG

#pull in config file to get installer url
source /etc/allevia/ninja/ninja_installer.conf

#check if successfully imported var $ninjaUrl
if [ -z "$ninjaUrl" ];
    then echo "ninjaUrl is null"
    echo "$(ls /etc/allevia/ninja/)"
    echo "$(cat /etc/allevia/ninja/ninja_installer.conf)"
    exit 1
fi

#check to see if NinjaOne is already installed
ninjaAgent=$(ls /Applications/ | grep --include=GLOB "NinjaRMMAgent*")
if ! [ -z "$ninjaAgent" ];
then
    echo "NinjaOne agent is already installed!"
    exit 0
fi

#get name of the installer from the url/server
installer=$(echo $ninjaUrl | cut -d'/' -f7)
echo $installer

#Download Package    
curl -O $(echo -e $ninjaUrl)
echo "Downloading from $ninjaUrl"

#Run Package installer
echo "running installer:"
/usr/sbin/installer -pkg ./$installer -target /

rm -f ./$installer

exit 0