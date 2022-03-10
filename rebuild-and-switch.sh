#!/run/current-system/sw/bin/fish

pushd ~/.nix
darwin-rebuild switch --flake .
popd -
