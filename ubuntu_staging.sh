#!/bin/bash

# Ubuntu version name
osType="ubuntu"
osName=$(mawk -F'=' '/^VERSION_CODENAME=/ {print $2}' /etc/os-release )
osStandardName="wily"
# Config params
dotnetVersion="1.0.1"
# PPA params
chromePPA="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
netcorePPA="deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ $osName main"
atomPPA="webupd8team/atom"
gdrivePPA="deb http://apt.insynchq.com/$osType $osStandardName non-free contrib"
# download URLs
nodejsURL="https://deb.nodesource.com/setup_7.x"

## Function addPPA: add a repository to sources.list
# param 1 - comment of the repository
# param 2 - repository
function addPPA () {

  echo "
## $1
$2" | tee -a $3 &> /dev/null
}

## Function stdMessage: echo a standard message of the script
# param 1 - a string representing the message to show
function stdMessage () {

  echo "----- $1 -----"
}

function installChrome () {

  # add and validate Chrome key
  addPPA 'Google Chrome' "$chromePPA" '/etc/apt/sources.list'
  stdMessage 'Added Google PPA'
  wget https://dl.google.com/linux/linux_signing_key.pub
  stdMessage 'Downloaded Google signing key'
  apt-key add linux_signing_key.pub
  stdMessage 'Added Google signing key to keyring'
}

function installNodejs () {

  curl -sL $nodejsURL | sudo -E bash -
  stdMessage 'Downloaded Node.js'
}

function installDotNet () {

  addPPA '.Net Core' "$netcorePPA" '/etc/apt/sources.list.d/dotnetdev.list'
  stdMessage 'Added .NET Core PPA'
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
  stdMessage 'Added .NET Core signing key to keyring'
}

function installAtom () {

  # add PPA
  add-apt-repository ppa:$atomPPA
}

function installGoogleDrive () {

  addPPA 'Insync: Google Drive' "$gdrivePPA" '/etc/apt/sources.list.d/insync.list'
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C
  stdMessage 'Added Insync PPA'
}

function installTLP () {

  add-apt-repository ppa:linrunner/tlp -y
}

function install () {

  installChrome
  installDotNet
  installNodejs
  installAtom
  installGoogleDrive
  apt-get update -y
  apt-get upgrade -y
  apt-get install git-core preload 7zip unrar zip unzip libunwind8 libunwind8-dev gettext libicu-dev liblttng-ust-dev libcurl4-openssl-dev libssl-dev uuid-dev
  apt-get install -y git google-chrome-stable atom nodejs "dotnet-dev-$dotnetVersion" insync unity-tweak-tool compizconfig-settings-manager zsh
  apt-get update -y
  apt-get upgrade -y
  apt-get clean -y
  apt-get autoremove -y
}

function configNodejs () {

  # Setup npm global packages installation
  mkdir ~/.npm-packages
  echo 'prefix=${HOME}/.npm-packages' | tee -a ~/.npmrc
  echo 'NPM_PACKAGES="${HOME}/.npm-packages"

  PATH="$NPM_PACKAGES/bin:$PATH"

  # Unset manpath so we can inherit from /etc/manpath via the `manpath` command
  unset MANPATH # delete if you already modified MANPATH elsewhere in your config
  export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"' | tee -a ~/.bashrc

  npm install --global npm@latest
  npm install --global yo
  npm install --global bower
  npm install --global generator-aspnet
}

function configProg () {

  configNodejs
  apt-get install tlp tlp-rdw
  tlp start
}

function beautify () {

  apt-add-repository ppa:tista/adapta -y
  apt update
  apt install adapta-gtk-theme
  gsettings set com.canonical.Unity.Launcher launcher-position Bottom
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  xdg-open http://magenest.com/power-up-and-beautify-your-terminal-by-zsh
}

install
configProg
beautify
