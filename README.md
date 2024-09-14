# My Nix configuration

## Install

### Enable Full Disk Access for Terminal

Some user settings require Full Disk Access to be enabled for the app that is running `darwin-rebuild switch`. After VSCodium and iTerm2 get installed you will need to enable Full Disk Access for them too if you want to run `darwin-rebuild switch` in them.

### Run the script

The following will install Nix, clone this repository in `~/.nix`, and setup the flake from `flake.nix`.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DimitarNestorov/.nix/master/setup.sh)"
```

### Log out

After the script runs successfully log out and log back in for all settings to apply
