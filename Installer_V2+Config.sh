#!/bin/bash

RED="\e[91m"
GREEN="\e[92m"
NORMAL="\e[0m"
COIN="\e[35m"
BLEU="\e[104m"
ccl="\e[1;49;93m"
Dossier=$(pwd)
DISTRO="unknown"

echo -e $RED 
echo " Installer script for : "
echo
echo -e $GREEN "* ODR-mmbTools: "
echo "  *   ODR-DabMux "
echo "  *   ODR-AudioEnc "
echo "  *   ODR-PadEnc "
echo "  *   PadTool "
echo "  *   DABlin "
echo "  *   Auxiliary scripts "
echo "  *   The FDK-AACv2 library with DAB+ patch "
echo "  *   Supervisor (automatisation of all tools) "
echo
echo "  *   Preconfigured multiplex with DLS and SLS (Slideshows)

#
# and all required dependencies for a
# Debian and Raspbian stable system.
#
# Requires: sudo"
echo -e $NORMAL

if [ $(lsb_release -d | grep -c wheezy) -eq 1 ]; then
echo -e $RED
echo "Error, debian wheezy is not supported anymore"
echo -e $NORMAL
exit 1
fi

if [ $(lsb_release -d | grep -c Debian) -eq 1 ] && [ $(lsb_release -sc | grep -c jessie) -eq 1  ]; then
	DISTRO="jessie"
echo -e "deb-src http://ftp.debian.org/debian/ jessie main contrib non-free" | sudo tee /etc/apt/sources.list.d/odr.list
        LIST_APT="ok"
fi
if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ] && [ $(lsb_release -sc | grep -c jessie) -eq 1 ]; then
	DISTRO="jessie"
echo -e "deb-src http://raspbian.raspberrypi.org/raspbian/ jessie main contrib non-free rpi" | sudo tee /etc/apt/sources.list.d/odr.list
	LIST_APT="ok"
fi


if [ $(lsb_release -d | grep -c Debian) -eq 1 ] && [ $(lsb_release -sc | grep -c stretch) -eq 1 ]; then
	DISTRO="stretch"
echo -e  "deb-src http://ftp.debian.org/debian/ stretch main contrib non-free" | sudo tee /etc/apt/sources.list.d/odr.list
        LIST_APT="ok"
fi
if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ] && [ $(lsb_release -sc | grep -c stretch) -eq 1 ]; then
	DISTRO="stretch"
echo -e "deb-src http://raspbian.raspberrypi.org/raspbian/ stretch main contrib non-free rpi" | sudo tee /etc/apt/sources.list.d/odr.list
        LIST_APT="ok"
fi

if [ $(lsb_release -d | grep -c Debian) -eq 1 ] && [ $(lsb_release -sc | grep -c buster) -eq 1 ] ; then
	DISTRO="buster"
echo -e  "deb-src http://ftp.debian.org/debian/ buster main contrib non-free" | sudo tee /etc/apt/sources.list.d/odr.list
        LIST_APT="ok"
fi
if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ] && [ $(lsb_release -sc | grep -c buster) -eq 1 ]; then
        DISTRO="buster"
echo -e "deb-src http://raspbian.raspberrypi.org/raspbian/ buster contrib non-free rpi" | sudo tee /etc/apt/sources.list.d/odr.list
	LIST_APT="ok"
fi


if [ $(lsb_release -d | grep -c Debian) -eq 1 ] && [ $(lsb_release -sc | grep -c bullseye) -eq 1 ] ; then
	DISTRO="bullseye"
echo -e  "deb-src http://ftp.debian.org/debian/ bullseye main contrib non-free" | sudo tee /etc/apt/sources.list.d/odr.list
        LIST_APT="ok"
fi

if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ] && [ $(lsb_release -sc | grep -c bullseye) -eq 1 ] ; then
	DISTRO="bullseye"
echo -e  "deb-src http://raspbian.raspberrypi.org/raspbian/ bullseye main contrib non-free rpi" | sudo tee /etc/apt/sources.list.d/odr.list
        LIST_APT="ok"
fi

if [ $(lsb_release -d | grep -c Debian) -eq 1 ] && [ $(lsb_release -sc | grep -c bookworm) -eq 1 ] ; then
	DISTRO="bookworm"
echo -e  "deb-src http://ftp.debian.org/debian/ bookworm main contrib non-free" | sudo tee /etc/apt/sources.list.d/odr.list
        LIST_APT="ok"

fi
if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ] && [ $(lsb_release -sc | grep -c bookworm) -eq 1 ]; then
        DISTRO="bookworm"
echo -e "deb-src http://raspbian.raspberrypi.org/raspbian/ bookworm contrib non-free rpi" | sudo tee /etc/apt/sources.list.d/odr.list
	LIST_APT="ok"
fi

echo
echo -e $COIN " Your version : $DISTRO "
echo "========================================================="
echo -e $NORMAL
echo



if [ "$DISTRO" == "unknown" ] ; then
    echo -e $RED
    echo "You seem to be running something else than"
    echo "debian jessie, stretch or buster. This script doesn't"
    echo "support your distribution."
    echo -e $NORMAL
    exit 1
fi

echo -e $RED
echo "This program will use sudo to install components on your"
echo "system. Please read the script before you execute it, to"
echo "understand what changes it will do to your system !"
echo
echo "There is no undo functionality here !"
echo -e $NORMAL

if [ "$UID" == "0" ]
then
    echo -e $RED
    echo "Do not run this script as root !"
    echo -e $NORMAL
    echo "Install sudo, and run this script as a normal user."
    exit 1
fi

which sudo
if [ "$?" == "0" ]
then
    echo "Press Ctrl-C to abort installation"
    echo "or Enter to proceed"

    read
else
    echo -e $RED
    echo -e "Please install sudo first $NORMAL using"
    echo " apt-get -y install sudo"
    exit 1
fi

# Fail on error
set -e



echo -e "$GREEN Updating debian package repositories $NORMAL"
sudo apt-get -y update

echo -e "$GREEN Installing essential prerequisites $NORMAL"
# some essential and less essential prerequisistes

sudo apt-get -y install build-essential git wget \
sox alsa-tools alsa-utils \
automake libtool mpg123 \
libasound2 libasound2-dev \
libjack-jackd2-dev jackd2 \
ncdu vim ntp links cpufrequtils \
libfftw3-dev \
libcurl4-openssl-dev \
libmagickwand-dev \
libvlc-dev vlc-data \
libfaad2 libfaad-dev \
supervisor \
pulseaudio libboost-system-dev \
python3-mako python3-requests

if [[ "$DISTRO" == "jessie" || "$DISTRO" == "stretch" ]] ; then
sudo apt-get -y install vlc-nox
sudo apt-get -y install libzmq3-dev libzmq3
elif [ "$DISTRO" == "buster" ] ; then
sudo apt-get -y install vlc-plugin-base
sudo apt-get -y install libzmq5-dev libzmq5 
elif [ "$DISTRO" == "stretch" ] ; then
sudo apt-get -y install libzmq3-dev libzmq5
elif [ "$DISTRO" == "bullseye" ] ; then
sudo apt-get -y install vlc-plugin-base
sudo apt-get -y install libzmq3-dev libzmq5
elif [ "$DISTRO" == "bookworm" ] ; then
sudo apt-get -y install vlc-plugin-base
sudo apt-get -y install libzmq3-dev libzmq5
fi

sudo apt-get -y install imagemagick

if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ] && [ $(lsb_release -sc | grep -c buster) -eq 1 ]; then
sudo apt-get -y install libboost-all-dev libusb-1.0-0-dev 
sudo apt-get -y install cmake
elif [ $(lsb_release -d | grep -c Raspbian) -eq 1 ] && [ $(lsb_release -sc | grep -c bullseye) -eq 1 ]; then
sudo apt-get -y install libboost-all-dev libusb-1.0-0-dev 
sudo apt-get -y install cmake
elif [ $(lsb_release -d | grep -c Ubuntu) -eq 1 ] && [ $(lsb_release -sc | grep -c bionic) -eq 1 ]; then
sudo apt-get -y install libuhd-dev
fi

echo -e "$GREEN Installing PadTool prerequisites $NORMAL"
# PadTool essential prerequisistes

sudo apt-get -y install python3 python3-pip chromium chromium-driver
sudo pip3 install selenium
sudo pip3 install imgkit
sudo pip3 install pillow
sudo pip3 install coverpy
sudo pip3 install sacad
sudo pip3 install discogs_client

# this will install boost, cmake and a lot more
# sudo apt-get -y build-dep uhd

# stuff to install from source

if [ ! -d "/home/$USER/dab" ];then
echo "Création du dossier dab ( /home/$USER/dab/ )!";
mkdir /home/$USER/dab
fi

cd /home/$USER/dab/

echo
echo -e "$GREEN PREREQUISITES INSTALLED $NORMAL"
### END OF PREREQUISITES

# ========== mmbTools ==========
if [ ! -d "/home/$USER/dab/mmbtools-aux" ];then
echo -e "$GREEN Fetching mmbtools-aux $NORMAL"
git clone https://github.com/DABodr/mmbtools-aux.git
pushd mmbtools-aux
cd zmqtest/zmq-sub/
make
popd
fi

# ========== EtiSnoop ==========
if [ ! -d "/home/$USER/dab/etisnoop" ];then
echo -e "$GREEN Fetching etisnoop $NORMAL"
git clone https://github.com/Opendigitalradio/etisnoop.git
pushd etisnoop
./bootstrap.sh
./configure
make
sudo make install
popd
fi

# ========== DabMux ==========
if [ ! -d "/home/$USER/dab/ODR-DabMux" ];then
echo -e "$GREEN Compiling ODR-DabMux $NORMAL"
git clone https://github.com/Opendigitalradio/ODR-DabMux.git
pushd ODR-DabMux
./bootstrap.sh
if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ]; then
./configure --enable-input-zeromq --enable-output-zeromq --with-boost-libdir=/usr/lib/arm-linux-gnueabihf
else
./configure
# ./configure --enable-input-zeromq --enable-output-zeromq --with-boost-libdir=/usr/lib/i386-linux-gnu
fi
make
sudo make install
popd
fi

# ========== DABlin ==========
if [ ! -d "/home/$USER/dab/dablin" ];then
echo -e "$GREEN Compiling DABlin $NORMAL"
sudo apt-get -y install libmpg123-dev libfaad-dev libsdl2-dev libgtkmm-3.0-dev
git clone https://github.com/Opendigitalradio/dablin.git
pushd dablin
mkdir build
cd build
cmake ..
make
sudo make install 
cd
popd
fi

echo -e "$GREEN Updating ld cache $NORMAL"
# update ld cache
sudo ldconfig

# ========== AudioEnc ==========
# For gstreamer option :
sudo apt-get -y install gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly libgstreamer-plugins-bad1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
# Audioenc :
if [ ! -d "/home/$USER/dab/ODR-AudioEnc" ];then
echo -e "$GREEN Compiling ODR-AudioEnc $NORMAL"
git clone https://github.com/Opendigitalradio/ODR-AudioEnc.git
pushd ODR-AudioEnc
./bootstrap
./configure --enable-alsa --enable-jack --enable-vlc --disable-uhd --enable-gst
make
sudo make install
popd
fi

# ========== PadEnc ==========
if [ ! -d "/home/$USER/dab/ODR-PadEnc" ];then
echo -e "$GREEN Compiling ODR-PadEnc $NORMAL"
git clone https://github.com/Opendigitalradio/ODR-PadEnc.git
pushd ODR-PadEnc
./bootstrap
./configure
make
sudo make install
popd
fi

# ========== PadTool ==========
if [ ! -d "/home/$USER/dab/PadTool" ];then
echo -e "$GREEN Compiling PadTool $NORMAL"
git clone https://github.com/fabcd14/PadTool
pushd PadTool
chmod +x ./padtool.py
popd
fi
clear
echo
echo -e "$GREEN Done installing all tools $NORMAL"
echo
echo
echo -e "$GREEN All the tools have been dowloaded to the /home/$USER/dab/ folder,"
echo -e "compiled and installed to /usr/local"
echo
echo -e "The stable versions have been compiled, i.e. the latest"
echo -e "'master' branch from the git repositories"
echo
echo -e "If you know there is a new release, and you want to update,"
echo -e "you have to go to the folder containing the tool, pull"
echo -e "the latest changes from the repository and recompile"
echo -e "it manually."
echo
echo -e "To pull the latest changes for ODR-DabMux, use:"
echo -e " cd $USER/dab/ODR-DabMux"
echo -e " git pull"
echo -e " ./bootstrap.sh"
echo -e " ./configure --enable-input-zeromq --enable-output-zeromq"
echo -e " make"
echo -e " sudo make install"
echo
echo -e "This example should give you the idea. For the options"
echo -e "for compiling the other tools, please see in the ODRinstaller_V2.sh"
echo -e "script what options are used. Please also read the README"
echo -e "and INSTALL files in the repositories. $NORMAL"
echo -e $RED
read -r -p "Do you want to start configuration script? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
   set -e
echo -e $NORMAL
echo 
cd $Dossier
sudo /etc/init.d/supervisor stop
sudo cp -v supervisord.conf /etc/supervisor/supervisord.conf
echo -e "[$GREEN OK $NORMAL]"
echo

echo " Copy configuration files"
sudo cp -R config /home/$USER/dab/
sudo sudo chmod -R 777  /home/$USER/dab/config
echo
echo -e "[$GREEN OK $NORMAL]"
echo

echo "Supervisor is restarting..."
sudo /etc/init.d/supervisor start
echo
echo -e "[$GREEN OK $NORMAL]"
echo
echo "Modification of the USER variable of the configuration files"
echo
for file in /home/$USER/dab/config/*/*.conf
do
  echo "Treatment of $file ..."
  echo
  sudo sed -i -e "s/azerty/$USER/g" "$file"
done 
echo
for file in /home/$USER/dab/config/*/*.ini
do
sudo sed -i -e "s/azerty/$USER/g" "$file"
done
echo
echo -e "[$GREEN OK $NORMAL]"
echo
echo "Symbolic links creation"
if [ -f /etc/supervisor/conf.d/mux.conf ]
then
sudo rm /etc/supervisor/conf.d/enc-*.conf
sudo rm /etc/supervisor/conf.d/mux.conf
fi
sudo ln -s /home/$USER/dab/config/supervisor/ /etc/supervisor/conf.d/
sudo supervisorctl reread 
sudo supervisorctl update
echo
echo -e "$GREEN Successful configuration ! $NORMAL"
echo
echo -e "$ccl Opening your internet browser in 10 seconds"
echo -e "( http://localhost:8001 )"
echo
echo -e " User: $RED odr $ccl pass: $RED odr $ccl" 
echo 
echo " ctrl+c to exit"
echo
echo -e "$GREEN Remember to add this page to your favorites !"
sleep 10
sensible-browser http://localhost:8001 &
echo 
echo
echo -e "$NORMAL"
echo
fi
