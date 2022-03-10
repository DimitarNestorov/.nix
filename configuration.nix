{ self, config, pkgs, lib, inputs, ... }:
let
	# comma = import (pkgs.fetchFromGitHub {
	# 	owner = "nix-community";
	# 	repo = "comma";
	# 	rev = "54149dc417819af14ddc0d59216d4add5280ad14";
	# 	sha256 = "sha256-iSkHFMgYh31UDFZ5BZ9AHBivdgO0n2iCrYKjwAWxXvY=";
	# }) { pkgs = pkgs; };
in {
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"vscode"
	];

	environment = {
		# List packages installed in system profile. To search by name, run:
		# $ nix-env -qaP | grep wget
		systemPackages = with pkgs; [
			vscode # TODO: vscodium
			direnv
			htop
			imgcat
			iterm2
			comma
			colorls
			(callPackage ./iina.nix {})
		];
	};

	fonts = {
		enableFontDir = true;
		fonts = with pkgs; [
			(nerdfonts.override { fonts = ["JetBrainsMono"]; })
		];
	};

	programs.fish = {
		enable = true;

		shellAliases = {
			darwin-rebuild-switch = "~/.nix/rebuild-and-switch.sh";
			ls = "colorls";
		};

		# functions = {
		# 	fish_greeting = {
		# 		description = "Greeting to show when starting a fish shell";
		# 		body = "";
		# 	};
		# };

		# TODO: idof => osascript -e 'id of app "iTerm2"'
	};

	system.stateVersion = 4;
}
