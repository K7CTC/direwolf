#!/bin/bash

################################################################################
#       TITLE: Dire Wolf Sound Modem Installation Script                       #
#   DEVELOPER: Chris Clement (K7CTC)                                           #
# DESCRIPTION: Configures a Raspberry Pi for use with Dire Wolf.               #
################################################################################

#global variables
VERSION="v1.3"
TITLE="Dire Wolf Installer by K7CTC"
BACKTITLE="Raspberry Pi Dire Wolf Sound Modem Setup Script $VERSION"
CALLSIGN="N0CAL"
REGEXCALL="^[A-Z]{1,2}[0-9]{1}[A-Z]{1,3}$"
REGEXCALLSSIDLOWER="^[A-Z]{1,2}[0-9]{1}[A-Z]{1,3}[-]{1}[0-9]{1}$"
REGEXCALLSSIDUPPER="^[A-Z]{1,2}[0-9]{1}[A-Z]{1,3}[-]{1}[1]{1}[0-5]{1}$"

#process callsign command line argument (if number of arguments is equal to 1)
if [ $# -eq 1 ]
then
    #store argument (assumed to be a callsign) in ARG
    ARG=$1
    #convert ARG to upper case and store in UNVALIDATEDCALLSIGN
    UNVALIDATEDCALLSIGN=$(echo "$ARG" | tr '[:lower:]' '[:upper:]')
    #check UNVALIDATEDCALLSIGN against regular expressions
    if [[ $UNVALIDATEDCALLSIGN =~ $REGEXCALL || $UNVALIDATEDCALLSIGN =~ $REGEXCALLSSIDLOWER || $UNVALIDATEDCALLSIGN =~ $REGEXCALLSSIDUPPER ]]
    then
        #callsign is validated by moving it into the CALLSIGN variable
        CALLSIGN=$UNVALIDATEDCALLSIGN
    else
        echo "You entered an invalid callsign and/or SSID, please try again."
        echo "NOTE: This script will only recognize North American callsigns"
        echo "and your SSID must be an integer between 0 and 15 per APRS"
        echo "specifications.  EXAMPLES: W1AW or W1AW-6 or W1AW-15"
        echo
        exit 1
    fi
elif [ $# -gt 1 ]
then
    echo "ERROR: Invalid command syntax. Unexpected number of arguments."
    echo "USAGE: ./install [optional callsign]"
    echo
    exit 1
fi

#check to make sure user has not executed the script via sudo
if [ "`whoami`" = "root" ]
then
    echo "Script cannot be run as root. Try './install.sh'"
    exit 1
fi

#check connectivity to raspberrypi.org (we'll need this server to obtain required packages)
ping raspberrypi.org -c 1
if [ $? != 0 ]
then
    echo "Unable to communicate with raspberrypi.org at this time.  Check your network"
    echo "connection and try again."
    exit 1
fi

#check connectivity to github.com (we'll need this server to obtain Dire Wolf source)
ping github.com -c 1
if [ $? != 0 ]
then
    echo "Unable to communicate with github.com at this time.  Check your network"
    echo "connection and try again."
    exit 1
fi

#function: get amateur radio callsign from user
function whiptailCallsign {
    #local variables
    #regex to match typical north american callsign with or without SSID
    #local REGEXCALL="^[A-Z]{1,2}[0-9]{1}[A-Z]{1,3}$"
    #local REGEXCALLSSIDLOWER="^[A-Z]{1,2}[0-9]{1}[A-Z]{1,3}[-]{1}[0-9]{1}$"
    #local REGEXCALLSSIDUPPER="^[A-Z]{1,2}[0-9]{1}[A-Z]{1,3}[-]{1}[1]{1}[0-5]{1}$"
    local SUCCESS=null
    until [ $SUCCESS = "true" ]
    do
        #get callsign from user
        INPUT=$(whiptail --title "$TITLE" --backtitle "$BACKTITLE" --fb --nocan\
cel --inputbox "Enter the callsign to be used with Dire Wolf with or without SS\
ID. (Examples: W1AW or W1AW-6 or W1AW-15)" 14 58 3>&1 1>&2 2>&3)
        #make the callsign upper case
        CALLSIGN=${INPUT^^}
        if [[ $CALLSIGN =~ $REGEXCALL || $CALLSIGN =~ $REGEXCALLSSIDLOWER || $CALLSIGN =~ $REGEXCALLSSIDUPPER ]]
        then
            SUCCESS=true
        else
            whiptail --title "$TITLE" --backtitle "$BACKTITLE" --fb --msgbox "Y\
ou entered an invalid callsign and/or SSID, please try again.  NOTE: This scrip\
t will only recognize North American callsigns and your SSID must be an integer\
 between 0 and 15 per APRS specifications." 14 58
            CALLSIGN="N0CAL"
            SUCCESS=false
        fi
    done
}

#get user callsign if not provided via command line argument
if [ "$CALLSIGN" = "N0CAL" ]
then
    whiptailCallsign
fi

#clear terminal window
clear
echo "Dire Wolf Sound Modem Installation Script by Chris Clement (K7CTC) $VERSION"
echo "-----------------------------------------------------------------------"

echo
echo "---------------"
echo "Installing required packages (cmake libasound2-dev libudev-dev)..."
echo "---------------"
sudo apt-get install -y cmake libasound2-dev libudev-dev

echo
echo
echo "---------------"
echo "Cloning Dire Wolf git repository to /home/pi/git/wb2osz/direwolf, please wait..."
echo "---------------"
git clone https://github.com/wb2osz/direwolf /home/pi/git/wb2osz/direwolf
cd /home/pi/git/wb2osz/direwolf

echo
echo
echo "---------------"
echo "Checking out the dev branch, please wait..."
echo "---------------"
git checkout dev

echo
echo
echo "---------------"
echo "Compiling Dire Wolf, please wait..."
echo "---------------"
mkdir build && cd build
cmake ..
make

echo
echo
echo "---------------"
echo "Installing Dire Wolf, please wait..."
echo "---------------"
sudo make install

echo
echo
echo "---------------"
echo "Installing Raspberry Pi specific configuration files..."
echo "---------------"
#first we need to revert back to the stable branch
git checkout 1.5
#then we can go back to the direwolf directory and run install-rpi
cd /home/pi/git/wb2osz/direwolf
make install-rpi
#then write out the config file to the pi home folder
echo "#direwolf.conf generated by PiERS setup script" > /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#additional options and information can be obtained here:" >> /home/pi/direwolf.conf
echo "#https://github.com/wb2osz/direwolf/tree/master/doc" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#audio device (need to determine if this line is necessary)" >> /home/pi/direwolf.conf
echo "ADEVICE plughw:1,0" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#number of audio channels: 1 or 2" >> /home/pi/direwolf.conf
echo "ACHANNELS 1" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#channel properties..." >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#channel number" >> /home/pi/direwolf.conf
echo "CHANNEL 0" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#callsign with optional SSID" >> /home/pi/direwolf.conf
echo "MYCALL $CALLSIGN" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#modem speed" >> /home/pi/direwolf.conf
echo "MODEM 1200" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#PTT configuration" >> /home/pi/direwolf.conf
echo "PTT /dev/ttyUSB0 RTS" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#fixbits (see Dire Wolf documentation)" >> /home/pi/direwolf.conf
echo "FIX_BITS 1 APRS" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#virtual TNC server properties..." >> /home/pi/direwolf.conf
echo  >> /home/pi/direwolf.conf
echo "#AGWPE TCPIP socket interface port" >> /home/pi/direwolf.conf
echo "AGWPORT 9292" >> /home/pi/direwolf.conf
echo >> /home/pi/direwolf.conf
echo "#KISS protocol over TCPIP socket interface port" >> /home/pi/direwolf.conf
echo "KISSPORT 7373" >> /home/pi/direwolf.conf

echo
echo
echo "---------------"
echo "Configuring Dire Wolf to execute during boot..."
echo "---------------"
mkdir /home/pi/.config/autostart
cp /usr/local/share/applications/direwolf.desktop /home/pi/.config/autostart/direwolf.desktop

echo
echo
echo "---------------"
echo "Dire Wolf installation finished!"
echo "---------------"
echo "Dire Wolf installation is complete!  You should now see a Dire Wolf"
echo "shortcut on your desktop and the application will load automatically"
echo "on subsequent boots.  Please note, you must attach the USB audio adapter"
echo "and USB to serial adapter in the correct ports prior to next boot or"
echo "Dire Wolf will exit upon launch.  It is recommended that you shut down"
echo "the Pi at this time with the command:"
echo
echo "shutdown now"
echo
exit 0
