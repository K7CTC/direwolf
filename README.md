# Dire Wolf Sound Modem Raspberry Pi Installation Script

This script automates the process of getting the Dire Wolf sound modem up and running on a Raspberry Pi.

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

# Prerequisites

You will of course need a Raspberry Pi.  Additionally you will need to install 

You will need to obtain the 


```bash
./direwolf_setup.sh
```

Follow the instructions provided by the setup script.
