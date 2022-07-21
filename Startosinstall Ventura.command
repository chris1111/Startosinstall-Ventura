#!/bin/bash
# Startosinstall Ventura
# By chris1111
# Vars
apptitle="Startosinstall Ventura"
version="1.0"
# Set Icon directory and file 
iconfile="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.imac-aluminum-20.icns"
echo "Startosinstall Ventura"
echo "-------------------------------------"

response=$(osascript -e 'tell app "System Events" to display dialog "
Format your SSD or HD drive with Disk Utility.
Format your SSD into a single partition
macOS Extended Journaled /GUID Partition
Give it whatever name you want
After formatting, you must exit disk utility to continue installation\nCancel = Exit" buttons {"Cancel", "Disk Utility"} default button 2 with title "'"$apptitle"' '"$version"'" with icon POSIX file "'"$iconfile"'"  ')

action=$(echo $response | cut -d ':' -f2)

# Exit if Canceled
if [ ! "$action" ] ; then
  osascript -e 'display notification "Program closing" with title "'"$apptitle"'" subtitle "User cancelled"'
  exit 0
fi

osascript -e 'display notification "Program start" with title "'"$apptitle"'" subtitle "User select Disk Utility"' 
Sleep 1

osascript <<EOD

do shell script "open -F -a 'Disk Utility'"
delay 1
tell application "Disk Utility"
	activate
end tell
repeat
	if application "Disk Utility" is not running then exit repeat
end repeat
EOD

osascript <<EOD
tell application "Finder"
	set allVolumes to disks
	
	repeat with aVolume in allVolumes
		
		if (name of aVolume as text) is equal to "Ventura-HD" then
			set name of aVolume to "Ventura_HD"
			
		end if
	end repeat
end tell
EOD

echo "-------------------------------------"
echo "Volume Chooser
The Ventura-HD volume name will be used for Startosinstall" 
echo "-------------------------------------"
Sleep 2


# get Volume path
if [ "$2" == "" ]; then

echo  "`tput setaf 7``tput sgr0``tput bold``tput setaf 10`Move the volume to the window \ followed by [ENTER]`tput sgr0` `tput setaf 7``tput sgr0`  "

echo " " 
echo " " 

while [ -z "$Volume" ]; do
read Volume
done
if [ ! -d "$Volume" ]; then echo "$Volume not found"; exit; fi 
else
Volume="$2"
fi


Sleep 1
/usr/sbin/diskutil rename "$Volume" "Ventura-HD"
	
echo "-------------------------------------"
echo "Install macOS Ventura.app Chooser" 
echo "-------------------------------------"
Sleep 2

# get Installer path
if [ "$2" == "" ]; then

echo  "`tput setaf 7``tput sgr0``tput bold``tput setaf 10`Move to the window your Install macOS Ventura.app\ followed by [ENTER]`tput sgr0` `tput setaf 7``tput sgr0`  "

echo " " 
echo " " 

while [ -z "$Installer" ]; do
read Installer
done
if [ ! -d "$Installer" ]; then echo "$Installer not found"; exit; fi 
else
Installer="$2"
fi
	
Sleep 2


echo "Enter to the macOS startosinstall
The system will reboot when its finish.
:Type your password" 

echo " " 

sudo "$Installer"/Contents/Resources/startosinstall --agreetolicense --volume /Volumes/Ventura-HD --rebootdelay 5 --nointeraction

