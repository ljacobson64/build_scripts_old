#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit
fi

# The following list shows which versions of gcc, g++, and gfortran are
# available in which releases of Ubuntu.
#
#                     4.4  4.5  4.6  4.7  4.8  4.9   5    6    7
# precise  12.04 LTS   X    X    X
# trusty   14.04 LTS   X         X    X    X
# vivid    15.04       X         X    X    X    X
# xenial   16.04 LTS                  X    X    X    X
# yakkety  16.10                      X    X    X    X    X
# zesty    17.04                      X    X    X    X    X
# artful   17.10                      X    X         X    X    X

echo                                                             >> /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/     trusty universe" >> /etc/apt/sources.list
echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty universe" >> /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/     xenial universe" >> /etc/apt/sources.list
echo "deb-src http://archive.ubuntu.com/ubuntu/ xenial universe" >> /etc/apt/sources.list

# Make sure all the packages on the machine are up-to-date.
apt-get -y update
apt-get -y upgrade

# GCC 7 is not available in the package manager by default, so we must add the
# repository to apt in order to gain access.
#add-apt-repository ppa:ubuntu-toolchain-r/test
#apt-get -y update

# Download and install everything.
#apt-get -y install gcc-7   g++-7   gfortran-7
apt-get -y install gcc-6   g++-6   gfortran-6
apt-get -y install gcc-5   g++-5   gfortran-5
apt-get -y install gcc-4.9 g++-4.9 gfortran-4.9
apt-get -y install gcc-4.8 g++-4.8 gfortran-4.8
apt-get -y install gcc-4.7 g++-4.7 gfortran-4.7
apt-get -y install gcc-4.6 g++-4.6 gfortran-4.6
apt-get -y install gcc-4.4 g++-4.4 gfortran-4.4

# Configure the alternatives to make it easy to switch between different
# compiler versions. The --slave flags mean that whenever you switch versions of
# gcc, you switch versions of g++ and gfortran as well.
#update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7   700 --slave /usr/bin/g++ g++ /usr/bin/g++-7   --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6   600 --slave /usr/bin/g++ g++ /usr/bin/g++-6   --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-6
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5   500 --slave /usr/bin/g++ g++ /usr/bin/g++-5   --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-5
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 490 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-4.9
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 480 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-4.8
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 470 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-4.7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 460 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-4.6
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.4 440 --slave /usr/bin/g++ g++ /usr/bin/g++-4.4 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-4.4

# After running this script, use the command
#
#     $ sudo update-alternatives --config gcc
#
# and you will be presented with a list that looks similar to this:
#
#     There are 7 choices for the alternative gcc (providing /usr/bin/gcc).
#
#       Selection    Path              Priority   Status
#     ------------------------------------------------------------
#     * 0            /usr/bin/gcc-6     600       auto mode
#       1            /usr/bin/gcc-4.4   440       manual mode
#       2            /usr/bin/gcc-4.6   460       manual mode
#       3            /usr/bin/gcc-4.7   470       manual mode
#       4            /usr/bin/gcc-4.8   480       manual mode
#       5            /usr/bin/gcc-4.9   490       manual mode
#       6            /usr/bin/gcc-5     500       manual mode
#       7            /usr/bin/gcc-6     600       manual mode
#
# Simply choose the selection number for the version you want.
