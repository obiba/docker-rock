#!/bin/bash
set -e

# Microsoft repository and its signing key (signed-by keyring) for this Ubuntu release
curl -sSL -o packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/$(. /etc/os-release && echo $VERSION_ID)/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get update
ACCEPT_EULA=Y apt-get install -y msodbcsql18
apt-get install -y unixodbc-dev
