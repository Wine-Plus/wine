#!/bin/sh
# Install the packages needed to build Wine-Plus on Debian 12+/Ubuntu 22.04+.
# Run as root.
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  gcc make flex bison gettext ccache xz-utils curl git xvfb xauth \
  gcc-mingw-w64-x86-64 gcc-mingw-w64-i686 \
  libx11-dev libxext-dev libxrandr-dev libxi-dev libxcursor-dev libxcomposite-dev \
  libxfixes-dev libxinerama-dev libxrender-dev libxxf86vm-dev libxkbcommon-dev \
  libwayland-dev libfreetype-dev libfontconfig-dev libgnutls28-dev \
  libgl-dev libegl-dev libvulkan-dev ocl-icd-opencl-dev \
  libpulse-dev libasound2-dev libdbus-1-dev libudev-dev libusb-1.0-0-dev \
  libsdl2-dev libcups2-dev libkrb5-dev libpcap-dev libv4l-dev libsane-dev \
  libgphoto2-dev libunwind-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
