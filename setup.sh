#!/bin/bash

set -euxo pipefail

# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

/nix/var/nix/profiles/default/bin/nix --extra-experimental-features "nix-command flakes" run nixpkgs#git clone https://github.com/DimitarNestorov/.nix.git ~/.nix

# Delete nix.conf since it's managed by nix-darwin
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin

# Hide Nix Store from root
sudo chflags hidden /nix

# TODO: This command is going to fail, let's make a pause here to let me download Xcode and add it to the store, require me to press enter to continue
/nix/var/nix/profiles/default/bin/nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.nix

sudo chsh -s /run/current-system/sw/bin/fish dimitar
