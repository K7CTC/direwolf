# Dire Wolf Sound Modem Raspberry Pi Installation Script

This script automates the process of getting the Dire Wolf sound modem up and running on a Raspberry Pi.  It will only work with the standard Raspbian Buster image (2020-02-05) but the plan is to make it work with the lite image as well (then probably drop support for the standard image).

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
  * assumes one sound interface exists and defaults to it (external usb audio adapter)
  * sets number of audio channels equal to 1
  * specifies settings for channel 0 (channels start at 0)
  * sets the station callsign as provided
  * establishes modem baud rate of 1200
  * assumes a PTT configuration of: /dev/ttyUSB0 RTS
  * sets the FIX_BITS value equal to 1 (see Dire Wolf documentation)
  * establishes an AGWPE TCPIP socket interface on port 9292
  * establishes a KISS protocol over TCPIP socket interface on port 7373
* configures Dire Wolf to run at boot (via Pi menu "autostart" functionality, not ideal)

## Goals

The goal is to build an easy to use installer and quasi configuration utility for the Dire Wolf sound modem on a Raspberry Pi.  Presently, the best way to get the amazing Dire Wolf sound modem to work on a Raspberry Pi is to build it from source code.  Additional steps are necessary to ensure the proper Debian package dependencies are installed prior to compilation.  Once Dire Wolf installation is complete, the configuration file must be properly edited before the application will operate.  This installation script sidesteps all of that by simply asking your callsign and then taking care of the rest.

This is just the first iteration of this script.  I would like to implement a more robust way of runing Dire Wolf as a service so as not to be dependent on the Raspbian GUI.  Ideally this will run equally well on Raspbian Lite.  I plan to implement a command line switch or possibly just script logic to to a standard install under Raspbian or a more streamlined install under Raspbian Lite.

## Required Hardware

* Raspberry Pi 3 B+ or Raspberry Pi 4
* microSD card
* USB Audio Adapter
* USB to Serial adapter

## Recommended Hardware

* [Plugable USB Audio Adapter](https://plugable.com/products/usb-audio)
* [GearMo 12" USB to RS232 Serial Adapter FTDI Chip 920K w/LED](https://www.gearmo.com/shop/12-inch-usb-to-rs232-serial-adapter-ftdi-chip/)
* [Tera Grand USB to RS232 Serial Adapter FTDI Chip](https://www.amazon.com/gp/product/B00BUZ0K68/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
* [SanDisk Ultra 32GB microSD Card](https://www.amazon.com/gp/product/B073JWXGNT/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)

## Prerequisites

You will of course need a Raspberry Pi.  Additionally, you will need a micro SD card loaded with 2020-02-05-raspbian-buster.img which can be obtained [here](http://downloads.raspberrypi.org/raspbian/images/raspbian-2020-02-07/2020-02-05-raspbian-buster.zip).  Please be sure to complete the following steps before continuing:

* Connect your Pi to a wired or wireless network.
* Complete the Welcome to Raspberry Pi wizzard (uncluding installation of available updates).
* Disable the on-board audio chip:
  * sudo nano /boot/config.txt
  * change line: dtparam=audio=on to dtparam=audio=off
  * ctrl+o then enter (to save file)
  * crtl+x (to exit the nano editor)
  * shutdown now
  * power cycle the Pi

## Installation

First things first, you will want to clone this repository to your Pi.  This can be accomplished by opening a new terminal window and entering:

```bash
cd ~
git clone https://github.com/k7ctc/direwolf git/k7ctc/direwolf
```

From here you will want to navigate to the newly created local repository:

```bash
cd git/k7ctc/direwolf
```

And simply run the installation script:

```bash
./install.sh
```

Follow the instructions provided by the setup script.

## Todo

* add command line argument to specify graphical (Raspbian) or non-graphical (Raspbian Lite) installation.
* add optional command line argument to pass amateur callsign into the script, thus making it a non-interactive install.
* figure out how to configure Dire Wolf to run automatically at boot as a background service.
* preferably one that can be monitored and restarted if, let's say, it crashes.
