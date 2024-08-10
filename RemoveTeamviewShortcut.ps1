#this is delete the shortcut that got installed 
#with Teamviewer  Unattended Access that was deployed through NinjaOne

#PaulG
#23 May 2024

$shortcut = "C:\Users\Public\Desktop\TeamViewer Host.lnk"

$shortcutExists = test-path -path $shortcut

if  ($shortcutExists){
    remove-item $shortcut
}

exit 0