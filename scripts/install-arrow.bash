#!/bin/bash

apt-get update
apt-get install -y ca-certificates lsb-release wget
wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
apt-get install -y ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
apt-get update
apt-get install -y libarrow-dev # For C++
apt-get install -y libarrow-glib-dev # For GLib (C)
apt-get install -y libarrow-dataset-dev # For Apache Arrow Dataset C++
apt-get install -y libarrow-flight-dev # For Apache Arrow Flight C++
# Notes for Plasma related packages:
#   * You need to enable "non-free" component on Debian GNU/Linux
#   * You need to enable "multiverse" component on Ubuntu
#   * You can use Plasma related packages only on amd64
apt-get install -y libplasma-dev # For Plasma C++
apt-get install -y libplasma-glib-dev # For Plasma GLib (C)
apt-get install -y libgandiva-dev # For Gandiva C++
apt-get install -y libgandiva-glib-dev # For Gandiva GLib (C)
apt-get install -y libparquet-dev # For Apache Parquet C++
apt-get install -y libparquet-glib-dev # For Apache Parquet GLib (C)



# https://arrow.apache.org/install/
apt-get update
apt-get install -y ca-certificates lsb-release wget
if [ $(lsb_release --codename --short) = "stretch" ]; then
  tee /etc/apt/sources.list.d/backports.list <<APT_LINE
deb http://deb.debian.org/debian $(lsb_release --codename --short)-backports main
APT_LINE
fi
# get the LATEST version of Arrow
wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
apt-get install -y ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
apt-get update
apt-get install -y libarrow-dev # For C++
apt-get install -y libarrow-glib-dev # For GLib (C)
apt-get install -y libarrow-dataset-dev # For Arrow Dataset C++
apt-get install -y libarrow-flight-dev # For Flight C++
apt-get install -y libparquet-dev # For Apache Parquet C++
apt-get install -y libparquet-glib-dev # For Apache Parquet GLib (C)
