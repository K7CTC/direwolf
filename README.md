# Dire Wolf Sound Modem Raspberry Pi Installation Script

This script automates the process of getting the Dire Wolf sound modem up and running on a Raspberry Pi.  It will only work with the standard Raspbian Buster image (2020-02-05) but the plan is to make it work with the Raspbian Lite image as well.

What it does:

* accepts and validates an amateur callsign provided via command line argument
* checks to make sure script has not been executed with root proveleges
* prompts user for callsign (via whiptail) if not provided via command line argument
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

The goal is to build an easy to use installer/configuration utility for the Dire Wolf sound modem on a Raspberry Pi.  Presently, the best way to get the amazing Dire Wolf sound modem to work on a Raspberry Pi is to build it from source code.  Additional steps are necessary to ensure the proper Debian package dependencies are installed prior to compilation.  Once Dire Wolf installation is complete, the configuration file must be properly edited before the application will operate.  This installation script sidesteps all of that by simply asking your callsign and then taking care of the rest.

This is just the first iteration of this script.  I would like to implement a more robust way of runing Dire Wolf as a service so as not to be dependent on the Raspbian GUI.  Ideally this will run equally well on Raspbian Lite.  I plan to implement a command line switch or possibly just script logic to to a standard install under Raspbian or a more streamlined install under Raspbian Lite.

## Required Hardware

* Raspberry Pi 3 B+ or Raspberry Pi 4
* microSD card
* Transceiver Interface (audio & PTT)

## Recommended Hardware

* [TigerTronics SignaLink USB](https://www.tigertronics.com)
* [Plugable USB Audio Adapter](https://plugable.com/products/usb-audio)
* [GearMo 12" USB to RS232 Serial Adapter FTDI Chip 920K w/LED](https://www.gearmo.com/shop/12-inch-usb-to-rs232-serial-adapter-ftdi-chip)
* [Tera Grand USB to RS232 Serial Adapter FTDI Chip](https://www.amazon.com/gp/product/B00BUZ0K68/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
* [SanDisk Ultra 32GB microSD Card](https://www.amazon.com/gp/product/B073JWXGNT/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)

## Prerequisites

Once you have gathered your hardware you will need to load you microSD card with 2020-02-05-raspbian-buster.img which can be obtained [here](http://downloads.raspberrypi.org/raspbian/images/raspbian-2020-02-07/2020-02-05-raspbian-buster.zip).  I highly recommend [belenaEtcher](https://www.balena.io/etcher) for flashing the image to your microSD card.  Please be sure to complete the following steps before continuing:

* Connect your Pi to a wired or wireless network.
* Complete the Welcome to Raspberry Pi wizzard (uncluding installation of available updates).
* Disable the on-board audio chip.
* Shutdown and power cycle the Pi.

### Disable On-Board Audio

To disable the on-board audio you will need to edit the boot configutation.  This file is located at /boot/config.txt and essentially functions like the BIOS interface of a normal desktop computer.  This file is read at boot and configures the Pi hardware accordingly.  Disabling the on-board audio is as simple as launching a terminal window and entering the following command:

```bash
sudo nano /boot/config.txt
```

This will open the config.txt file in the nano text editor.  From here, scroll to near the bottom of the file and locate this line:

```nano
dtparam=audio=on
```

Then, modify this line to read...

```nano
dtparam=audio=off
```

To save and exit you will first press **ctrl+o** then **enter** (saves changes), then press **ctrl+x** to exit.  Next, you will need to shutdown and power cycle the Pi.  Enter the following command and wait for the green led to stop blinking before power cycling the Pi:

```bash
shutdown now
```

When the Pi boots back up you will notice the speaker icon in the menu bar now has an "X" over it.

## Installation

First things first, you will want to clone this repository to your Pi.  This can be accomplished by opening a new terminal window and entering:

```bash
cd /home/pi
git clone https://github.com/k7ctc/direwolf git/k7ctc/direwolf
```

From here you will want to navigate to the newly created local repository:

```bash
cd git/k7ctc/direwolf
```

Now you can run install.sh in one of two ways.  The first (and preferable) option is to specify your callsign via command line argument.  The script will "validate" your input as a North American callsign with or without SSID.

Examples:

```bash
./install.sh W1AW
```

```bash
./install.sh W1AW-6
```

```bash
./install.sh W1AW-15
```

Alternatively you can simply run the installation script without the command line argument and subsequently be prompted to enter your callsign:

```bash
./install.sh
```

If direwolf-setup.sh refuses to execute, you may need to modify the file permissions to allow for execution.  This is accomplished using the [chmod](https://en.wikipedia.org/wiki/Chmod) with either of the following commands:

```bash
chmod 755 ./piers_setup.sh
```

or

```bash
chmod +x ./piers_setup.sh
```

Simply follow the instructions provided by the setup script.

## Next Steps

After connecting your USB to RS232 and USB Audio Adapter then rebooting your Pi, you will see Dire Wolf launch in a terminal window once the Pi desktop loads.  Congratulations, you now have a working copy of Dire Wolf running on your Pi.  There are a few additional items that you will want to address, or at least be aware of.

### Official Dire Wolf Documentation

To gain understanding on how this software functions I highly recommend that you read the official Dire Wolf documentation.  This documentation can be viewed [here](https://github.com/wb2osz/direwolf/tree/master/doc).

### Dire Wolf Configuration File

The installation script will create a basic configuration file on your behalf.  This file is located at /home/pi/direwolf.conf.  You can edit this file with your preferred text editor.  You may want to open it and look it over to gain a better understanding of what it does.  Please refer to the official Dire Wolf documentation to see what additional configuration options are available.

### Adjusting Audio Levels

This is one of those things that is going to be different for everyone.  Such is the case when dealing with AX.25 over analog FM.  You are likely going to need to adjust audio levels either (a) from your transceiver or (b) from your USB Audio Adapter or probably both.  Please refer to your owners manual for instructions on adjusting your rig audio levels.

As far as the USB Audio Adapter on the Pi goes...  You can right click on the speaker icon located in the upper left of your screen.  Then, select your audio adapter (there should be only one).  This sets your USB Audio Adapter as the system default.  Once this has been completed, you will see the red "X" disappear from the speaker icon.  Again, right click on the speaker icon and you will notice a context menu revealing the device options.  Clicking this will bring up a basic mixer interface where you can adjust the audio levels as well as mute/unmute the input and output.

## Operating System Dependencies

The following Debian packages are required for proper compilation and operation of Dire Wolf.  The installation script will automatically download and install them as well as any related package dependencies.  They are listed here for reference.

* cmake
* libasound2-dev
* libudev-dev

## Developed By

* **Chris Clement (K7CTC)** - [https://qrz.com/db/K7CTC](https://qrz.com/db/K7CTC)

## License

This project is licensed under the MIT License - see [LICENSE.md](LICENSE.md) for details

## Todo

* add logic to automatically perform a graphical (Raspbian) or non-graphical (Raspbian Lite) installation.
* ~~add optional command line argument to pass amateur callsign into the script, thus making it a non-interactive install.~~
* figure out how to configure Dire Wolf to run automatically at boot as a background service.
* preferably one that can be monitored and restarted if, let's say, it crashes.
