{ self, config, pkgs, lib, inputs, ... }:
let

in {
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"vscode"
	];

	nixpkgs.overlays = [  ];
	
	environment = {
		# List packages installed in system profile. To search by name, run:
		# $ nix-env -qaP | grep wget
		systemPackages = [
			# TODO: pkgs.vscodium
			pkgs.vscode
			pkgs.direnv
			pkgs.htop
			pkgs.imgcat
			(pkgs.callPackage ./iina.nix {})
		];
	};

	programs.fish = {
		enable = true;

		shellAliases = {
			darwin-rebuild-switch = "~/.nix/rebuild-and-switch.sh";
		};
	};

	system.stateVersion = 4;
}
