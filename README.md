# Dire Wolf Sound Modem Raspberry Pi Installation Script

This script automates the process of getting the Dire Wolf sound modem up and running on a Raspberry Pi.

What it does:
* checks to make sure script has not been executed with root proveleges
* obtains the user's amateur radio callsign (regex checks help to validate as a north american callsign)
* installs required packages (cmake libasound2-dev libudev-dev)
* clones the [Dire Wolf github repository](https://github.com/wb2osz/direwolf) to /home/pi/git/wb2osz/direwolf
* checks out the dev branch (currently v1.6 D)
* compiles Dire Wolf from source
* installs Dire Wolf
* checks out the stable branch (currently v1.5)
* installs Raspberry Pi specific files
* writes out a basic configuration file
  *assumes one sound interface exists and defaults to it (external usb audio adapter)
  *sets number of audio channels equal to 1
  *specifies settings for channel 0 (channels start at 0)
  *sets the station callsign as provided
  *establishes modem baud rate of 1200
  *assumes a PTT configuration of: /dev/ttyUSB0 RTS
  *sets the FIX_BITS value equal to 1 (see Dire Wolf documentation)
  *establishes an AGWPE TCPIP socket interface on port 9292
  *establishes a KISS protocol over TCPIP socket interface on port 7373
*configures Dire Wolf to run at boot (via Pi menu "autostart" functionality, not ideal)

# Prerequisites

You will of course need a Raspberry Pi.  Additionally, you will need a micro SD card loaded with 2020-02-05-raspbian-buster.img which can be obtained [here](http://downloads.raspberrypi.org/raspbian/images/raspbian-2020-02-07/2020-02-05-raspbian-buster.zip).  Please be sure to complete the following steps before continuing:

1. Connect your Pi to a wired or wireless network.
2. Complete the Welcome to Raspberry Pi wizzard (uncluding installation of available updates).
3. Disable the on-board audio chip:
  a. sudo nano /boot/config.txt
  b. change line: dtparam=audio=on to dtparam=audio=off
  c. ctrl+o then enter (to save file)
  d. crtl+x (to exit the nano editor)
  e. shutdown now
  f. power cycle the Pi

# Installation

First things first, you will want to clone this repository to your Pi.  This can be accomplished by opening a new terminal window and entering:

```bash
cd ~
git clone https://github.com/k7ctc/direwolf git/k7ctc/direwolf
```

From here you will want to navigate to the newly created local repository:

```bash
cd git/k7ctc/direwolf
```



You will need to obtain the 


```bash
./direwolf_setup.sh
```

Follow the instructions provided by the setup script.

## Todo

* add command line argument to specify graphical (Raspbian) or non-graphical (Raspbian Lite) installation.
* add optional command line argument to pass amateur callsign into the script, thus making it a non-interactive install.
* figure out how to configure Dire Wolf to run automatically at boot as a background service.
* preferably one that can be monitored and restarted if, let's say, it crashes.
