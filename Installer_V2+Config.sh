#!/bin/bash

# Define color variables for formatting
RED="\e[91m"
GREEN="\e[92m"
NORMAL="\e[0m"

# Check for superuser privileges
if [ "$(id -u)" -eq 0 ]; then
    echo -e $RED
    echo "Please do not run this script as root."
    echo -e $NORMAL
    exit 1
fi

# Function to add Debian sources to the repository list
add_debian_sources() {
    local distro="$1"
    echo -e "deb-src http://ftp.debian.org/debian/ $distro main contrib non-free" | sudo tee /etc/apt/sources.list.d/odr.list
}

# Function to install packages
install_packages() {
    local packages=("$@")
    sudo apt-get -y update
    sudo apt-get -y install "${packages[@]}"
}

# Determine the Debian distribution
if [ $(lsb_release -d | grep -c Debian) -eq 1 ]; then
    case $(lsb_release -sc) in
        jessie)
            DISTRO="jessie"
            add_debian_sources "$DISTRO"
            ;;
        stretch)
            DISTRO="stretch"
            add_debian_sources "$DISTRO"
            ;;
        buster)
            DISTRO="buster"
            add_debian_sources "$DISTRO"
            ;;
        bullseye)
            DISTRO="bullseye"
            add_debian_sources "$DISTRO"
            ;;
        bookworm)
            DISTRO="bookworm"
            add_debian_sources "$DISTRO"
            ;;
        *)
            echo -e $RED
            echo "Your Debian distribution is not supported by this script."
            echo -e $NORMAL
            exit 1
            ;;
    esac
else
    echo -e $RED
    echo "You are not running a Debian-based system. This script only supports Debian."
    echo -e $NORMAL
    exit 1
fi

# List of essential prerequisites
essential_prerequisites=(
    build-essential
    git
    wget
    sox
    alsa-tools
    alsa-utils
    automake
    libtool
    mpg123
    libasound2
    libasound2-dev
    libjack-jackd2-dev
    jackd2
    ncdu
    vim
    ntp
    links
    cpufrequtils
    libfftw3-dev
    libcurl4-openssl-dev
    libmagickwand-dev
    libvlc-dev
    vlc-data
    libfaad2
    libfaad-dev
    supervisor
    pulseaudio
    libboost-system-dev
)

# Check the Debian distribution for specific package requirements
case "$DISTRO" in
    buster)
        essential_prerequisites+=(vlc-plugin-base)
        install_packages "${essential_prerequisites[@]}"
        ;;
    *)
        essential_prerequisites+=(vlc-nox)
        install_packages "${essential_prerequisites[@]}"
        ;;
esac

# Additional package installation for specific Debian versions
if [ "$DISTRO" == "buster" ] || [ "$DISTRO" == "bookworm" ]; then
    install_packages libzmq5-dev libzmq5
fi

if [ "$DISTRO" == "jessie" ] || [ "$DISTRO" == "stretch" ]; then
    install_packages libzmq3-dev libzmq3
elif [ "$DISTRO" == "stretch" ]; then
    install_packages libzmq3-dev libzmq5
fi

# Additional package installation for Raspberry Pi
if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ]; then
    if [ "$DISTRO" == "buster" ] || [ "$DISTRO" == "bookworm" ]; then
        install_packages libboost-all-dev libusb-1.0-0-dev cmake
    fi
fi


# Clone and build mmbTools, EtiSnoop, DabMux, DABlin, AudioEnc, PadEnc, and PadTool
dab_dir="/home/$USER/dab"
mkdir -p "$dab_dir"
cd "$dab_dir"

# Clone and build mmbtools-aux if not already present
if [ ! -d "$dab_dir/mmbtools-aux" ]; then
    echo -e "$GREEN Fetching mmbtools-aux $NORMAL"
    git clone https://github.com/DABodr/mmbtools-aux.git
    pushd mmbtools-aux
    cd zmqtest/zmq-sub/
    make
    popd
fi

# Clone and build EtiSnoop if not already present
if [ ! -d "$dab_dir/etisnoop" ]; then
    echo -e "$GREEN Fetching etisnoop $NORMAL"
    git clone https://github.com/Opendigitalradio/etisnoop.git
    pushd etisnoop
    ./bootstrap.sh
    ./configure
    make
    sudo make install
    popd
fi

# Clone and build ODR-DabMux if not already present
if [ ! -d "$dab_dir/ODR-DabMux" ]; then
    echo -e "$GREEN Compiling ODR-DabMux $NORMAL"
    git clone https://github.com/Opendigitalradio/ODR-DabMux.git
    pushd ODR-DabMux
    ./bootstrap.sh
    if [ $(lsb_release -d | grep -c Raspbian) -eq 1 ]; then
        ./configure --enable-input-zeromq --enable-output-zeromq --with-boost-libdir=/usr/lib/arm-linux-gnueabihf
    else
        ./configure
    fi
    make
    sudo make install
    popd
fi

# Clone and build DABlin if not already present
if [ ! -d "$dab_dir/dablin" ]; then
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

# For gstreamer option :
sudo apt-get -y install gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly libgstreamer-plugins-bad1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev

# Clone and build ODR-AudioEnc if not already present
if [ ! -d "$dab_dir/ODR-AudioEnc" ]; then
    echo -e "$GREEN Compiling ODR-AudioEnc $NORMAL"
    git clone https://github.com/Opendigitalradio/ODR-AudioEnc.git
    pushd ODR-AudioEnc
    ./bootstrap
    ./configure --enable-alsa --enable-jack --enable-vlc --disable-uhd --enable-gst
    make
    sudo make install
    popd
fi

# Clone and build ODR-PadEnc if not already present
if [ ! -d "$dab_dir/ODR-PadEnc" ]; then
    echo -e "$GREEN Compiling ODR-PadEnc $NORMAL"
    git clone https://github.com/Opendigitalradio/ODR-PadEnc.git
    pushd ODR-PadEnc
    ./bootstrap
    ./configure
    make
    sudo make install
    popd
fi

echo
echo -e "$GREEN Done installing all tools $NORMAL"
echo
echo
echo -e "$GREEN All the tools have been downloaded to the $dab_dir folder,"
echo -e "compiled, and installed to /usr/local"
echo
echo -e "The stable versions have been compiled, i.e., the latest"
echo -e "'master' branch from the git repositories"
echo
echo -e "If you know there is a new release and you want to update,"
echo -e "you have to go to the folder containing the tool, pull"
echo -e "the latest changes from the repository, and recompile it manually."
echo
echo -e "To pull the latest changes for ODR-DabMux, use:"
echo -e " cd $dab_dir/ODR-DabMux"
echo -e " git pull"
echo -e " ./bootstrap.sh"
echo -e " ./configure --enable-input-zeromq --enable-output-zeromq"
echo -e " make"
echo -e " sudo make install"
echo
echo -e "This example should give you the idea. For the options for compiling the other tools,"
echo -e "please see in the script what options are used. Please also read the README"
echo -e "and INSTALL files in the repositories. $NORMAL"
echo -e $RED
read -r -p "Do you want to start the configuration script? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
   set -e
echo -e $NORMAL
echo 
cd "$dab_dir"
sudo /etc/init.d/supervisor stop
sudo cp -v supervisord.conf /etc/supervisor/supervisord.conf
echo -e "[$GREEN OK $NORMAL]"
echo

echo "Copy configuration files"
sudo cp -R config "$dab_dir"
sudo sudo chmod -R 777 "$dab_dir/config"
echo
echo -e "[$GREEN OK $NORMAL]"
echo

echo "Supervisor is restarting..."
sudo /etc/init.d/supervisor start
echo
echo -e "[$GREEN OK $NORMAL]"
echo
echo "Modification of the USER variable in the configuration files"
echo
for file in "$dab_dir/config"/*/*.conf; do
  echo "Processing $file ..."
  echo
  sudo sed -i -e "s/azerty/$USER/g" "$file"
done 

for file in "$dab_dir/config"/*/*.ini; do
    sudo sed -i -e "s/azerty/$USER/g" "$file"
done
echo
echo -e "[$GREEN OK $NORMAL]"
echo
echo "Creating symbolic links"
if [ -f /etc/supervisor/conf.d/mux.conf ]; then
    sudo rm /etc/supervisor/conf.d/enc-*.conf
    sudo rm /etc/supervisor/conf.d/mux.conf
fi
sudo ln -s "$dab_dir/config/supervisor/" /etc/supervisor/conf.d/
sudo supervisorctl reread 
sudo supervisorctl update
echo
echo -e "$GREEN Successful configuration! $NORMAL"
echo
echo -e "$ccl Opening your internet browser in 10 seconds"
echo -e "(http://localhost:8001)"
echo
echo -e "User: $RED odr $ccl pass: $RED odr $ccl" 
echo 
echo "Ctrl+C to exit"
echo
echo -e "$GREEN Remember to add this page to your favorites!"
sleep 10
sensible-browser http://localhost:8001 &
echo 
echo
echo -e "$NORMAL"
echo
fi
