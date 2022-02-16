#!/run/current-system/sw/bin/fish

cd ~/.nix
darwin-rebuild switch --flake .
