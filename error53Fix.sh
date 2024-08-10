#! /bin/bash

#Script to resolve error 53 that plagues Harmony Mac Users
#Error is caused by an Adobe plug-in for MS Office

#paulg
#28 May 2024

#Start Script

#create empty array to store EndUser's username
declare -a filterUsers

#create array with file paths of where each plug in could be, starting with Library directory, to be added to each user's home directory path later
filePaths=("Library/Group Containers/UBF8T346G9.Office/User Content/Startup/Word/linkCreation.dotm" "Library/Group Containers/UBF8T346G9.Office/User Content/Startup/Excel/SaveAsAdobePDF.xlam" "Library/Group Containers/UBF8T346G9.Office/User Content/Startup/Powerpoint/SaveAsAdobePDF.ppam" "Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Word/linkCreation.dotm" "Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Excel/SaveAsAdobePDF.xlam" "Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Powerpoint/SaveAsAdobePDF.ppam")

#get list of all usernames from the Users dir under root 
allUsers=$(ls /Users)

#filter out admin non-user accounts from usernames, add actuall usernames to the filteredUsers array
for user in $allUsers
do
    if [[ ! "$user" =~ .*localized.* ]] && [[ ! "$user" =~ .*Shared.* ]] && [[ ! $user =~ .*allevia.* ]] && [[ ! $user =~ .*Allevia.* ]]; then   
        filterUsers+=("$user")
    fi
done

#iterate through filterUsers array, check each file path for that user and remove the plugin if it exists
for user in "${filterUsers[@]}"
do
    for filePath in "${filePaths[@]}"
    do
        fullPath="/Users/$user/$filePath"
        if [ -f "$fullPath" ]; then
            rm "$fullpath"
            echo "Deleted $fullPath"
        fi
    done
done