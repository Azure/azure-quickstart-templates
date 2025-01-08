#!/bin/bash

set -e

# environment setup
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# authorize ROS GPG key
sudo apt update
sudo apt install -y curl gnupg2 lsb-release
curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

# add ROS package repositories to source list
sudo sh -c 'echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros2-latest.list'
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

# get the latest repository
sudo apt update

# install required tools
sudo apt install -y python-rosdep
sudo apt install -y python-pip
sudo apt install -y python3-pip
sudo apt install -y xvfb

# install ROS distro
sudo apt install -y ros-melodic-desktop-full
sudo apt install -y ros-dashing-desktop

# rosdep init
sudo rosdep init
