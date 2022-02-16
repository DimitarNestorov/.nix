#!/bin/zsh

# Go to home directory
cd

# Clone configuration
git clone https://github.com/dimitarnestorov/nix.git .nix

# Go to configuration folder
cd .nix

# Install nix
sh <(curl -L https://nixos.org/nix/install)

# Delete nix.conf since it's managed by nix-darwin
sudo rm /etc/nix/nix.conf

# Hide Nix Store from root
sudo chflags hidden /nix

# Setup run symlink
printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

nix build .\#darwinConfigurations.${HOST%%.*}.system --experimental-features "nix-command flakes"
./result/sw/bin/darwin-rebuild switch --flake .
