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


# Get input folder of usbdisk disk 
  usbdiskpath=`/usr/bin/osascript << EOT
    tell application "Finder"
        activate
        set folderpath to choose folder default location "/Volumes" with prompt "Select your SSD / HD"
    end tell 
    return (posix path of folderpath) 
  EOT`

# Parse disk volume
usbdisk=$( echo $usbdiskpath | awk -F '\/Volumes\/' '{print $2}' | cut -d '/' -f1 )
disknum=$( diskutil list | grep "$usbdisk" | awk -F 'disk' '{print $2}' | cut -d 's' -f1 )
devdisk="/dev/disk$disknum"
# check rdisk
devdiskr="/dev/rdisk$disknum"
# Get Drive size
drivesize=$( diskutil list | grep "disk$disknum" | grep "0\:" | cut -d "*" -f2 | awk '{print $1 " " $2}' )

source=$inputfile
dest="$drivesize $usbdisk (disk$disknum)"
outputfile=$devdiskr
check=$source
echo "⬇︎ "
echo "-------------------------------------"
echo "$usbdiskpath " 
echo "-------------------------------------"
Sleep 2	


# Get image file location
  imagepath=`/usr/bin/osascript << EOT
    tell application "Finder"
        activate
        set imagefilepath to choose file default location "/Applications" with prompt "Select your Install macOS Ventura.app"
    end tell 
    return (posix path of imagefilepath) 
  EOT`

# Parse vars for Install macOS
inputfile=$imagepath
echo "⬇︎ "	
echo "-------------------------------------"
echo "$inputfile "
echo "-------------------------------------"
Sleep 2

echo "Enter to the macOS startosinstall
The system will reboot when its finish.
:Type your password" 

echo " " 

sudo "$inputfile"/Contents/Resources/startosinstall --agreetolicense --volume /"$usbdiskpath" --rebootdelay 5 --nointeraction

