{ self, config, pkgs, lib, inputs, ... }:
{
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
			colorls
			iina
		];
	};

	fonts = {
		fontDir.enable = true;
		fonts = with pkgs; [
			(nerdfonts.override { fonts = ["JetBrainsMono"]; })
			(google-fonts.override { fonts = ["PublicSans"]; })
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

	security.pam.enableSudoTouchIdAuth = true;

	system.stateVersion = 4;
}
