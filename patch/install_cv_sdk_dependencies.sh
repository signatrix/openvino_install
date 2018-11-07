#!/bin/bash

echo
echo This script installs the following OpenVINO 3rd-party dependencies:
echo   1. FFmpeg and GStreamer libraries required for OpenCV and Inference Engine
echo   2. libusb library required for Myriad plugin for Inference Engine
echo

if [[ -f /etc/lsb-release ]]; then
    # Ubuntu
    sudo -E apt update
    sudo -E apt install -y  libpng-dev libcairo2-dev libpango1.0-dev libglib2.0-dev libgtk2.0-dev libgstreamer1.0-dev libswscale-dev libavcodec-dev libavformat-dev cmake libusb-1.0-0-dev
else
    # CentOS
    echo Additionally cmake, default gcc version 4.8.5 and Python 3.6 will be installed on CentOS
    echo

    # gcc
    sudo -E yum install -y centos-release-scl epel-release
    sudo -E yum install -y gcc gcc-c++ make glibc-static glibc-devel libstdc++-static libstdc++-devel libstdc++ libgcc \
                           glibc-static.i686 glibc-devel.i686 libstdc++-static.i686 libstdc++.i686 libgcc.i686 cmake

    # FFmpeg and GStreamer for OpenCV
    sudo -E rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
    sudo -E yum install -y ffmpeg libusbx-devel gstreamer1 gstreamer1-plugins-base

    # Python 3.6 for Model Optimizer
    sudo -E yum install -y https://centos7.iuscommunity.org/ius-release.rpm
    sudo -E yum install -y python36u python36u-pip
fi
