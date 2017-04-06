#!/bin/bash
## Function addRepo: add a repository to sources.list
# param 1 - comment of the repository
# param 2 - repository
function addRepo () {

  echo "
## $1
$2" | tee -a $3
}

function stdMessage () {

  echo "----- $1 -----"
}

# Config
dotnetVersion="1.0.1"
# Repo variables
chromeRepo="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
netcoreRepo="deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ yakkety main"

addRepo 'Google Chrome repository' "$chromeRepo" '/etc/apt/sources.list' &> /dev/null
stdMessage 'Added Google repository'
wget https://dl.google.com/linux/linux_signing_key.pub
stdMessage 'Downloaded Google signing key'
apt-key add linux_signing_key.pub
stdMessage 'Added Google signing key to keyring'

addRepo '.Net Core repository' "$netcoreRepo" '/etc/apt/sources.list.d/dotnetdev.list' &> /dev/null
stdMessage 'Added .NET Core repository'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
stdMessage 'Added .NET Core signing key to keyring'

curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
stdMessage 'Downloaded Node.js'

# Update packages list
apt-get update

# Install packages
apt-get install -y google-chrome-stable
apt-get install -y "dotnet-dev-$dotnetVersion"
apt-get install -y nodejs
# Setup npm global packages installation
mkdir ~/.npm-packages
echo 'prefix=${HOME}/.npm-packages' | tee -a ~/.npmrc
echo 'NPM_PACKAGES="${HOME}/.npm-packages"

PATH="$NPM_PACKAGES/bin:$PATH"

# Unset manpath so we can inherit from /etc/manpath via the `manpath` command
unset MANPATH # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"' | tee -a ~/.bashrc

apt-get install -y git
npm install --global npm@latest
npm install --global yo
npm install --global bower
npm install --global generator-aspnet
