#!/bin/bash

#Creates a config file for NinjaOne deployments
#variables are pulled from Addigy's Policy Variables
#installer is a script ran at 4 PM each day, can be ran manually (ninjaInstaller_v1.0.sh)
#this needs to be deployed as Smart Software at Policy level in Addigy
#to have access to Addigy Policy Vars

#paulg
#17 May 2024

echo "starting script"
echo "creating directories"
mkdir -p /etc/allevia/ninja
echo "$(ls /etc/allevia)"
touch /etc/allevia/ninja/ninja_installer.conf
echo "created file $(ls /etc/allevia/ninja/), writing vars..."
echo -e "ninjaUrl=$ninjaInstaller\n" > /etc/allevia/ninja/ninja_installer.conf
echo "config file created"
echo "$(cat /etc/allevia/ninja/ninja_installer.conf)"
exit 0
