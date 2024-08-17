{ pkgs, lib, ... }:
{
	nix = {
		package = pkgs.nixFlakes;
		
		extraOptions = ''
experimental-features = nix-command flakes
'' + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
system = aarch64-darwin
'';
	};

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"Xcode.app"
		"google-chrome"
		"bartender"
	];

	environment = {
		# List packages installed in system profile. To search by name, run:
		# $ nix-env -qaP | grep wget
		systemPackages = with pkgs; [
			# TODO: _1password-gui
			darwin.xcode_15_1
			google-chrome
			bartender
			vscodium
			git
			direnv
			htop
			imgcat
			iterm2
			colorls
			iina
			tailscale
		];
	};

	fonts = {
		packages = with pkgs; [
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

		# https://github.com/LnL7/nix-darwin/issues/122#issuecomment-2272570087
		loginShellInit =
		let
			# We should probably use `config.environment.profiles`, as described in
			# https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
			# but this takes into account the new XDG paths used when the nix
			# configuration has `use-xdg-base-directories` enabled. See:
			# https://github.com/LnL7/nix-darwin/issues/947 for more information.
			profiles = [
				"/etc/profiles/per-user/$USER" # Home manager packages
				"$HOME/.nix-profile"
				"(set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)/nix/profile"
				"/run/current-system/sw"
				"/nix/var/nix/profiles/default"
			];

			makeBinSearchPath =
			lib.concatMapStringsSep " " (path: "${path}/bin");
		in
		''
			# Fix path that was re-ordered by Apple's path_helper
			fish_add_path --move --prepend --path ${makeBinSearchPath profiles}
			set fish_user_paths $fish_user_paths
		'';

		# functions = {
		# 	fish_greeting = {
		# 		description = "Greeting to show when starting a fish shell";
		# 		body = "";
		# 	};
		# };

		# TODO: idof => osascript -e 'id of app "iTerm2"'
	};

	programs.nix-index-database.comma.enable = true;

	security.pam.enableSudoTouchIdAuth = true;

	services.nix-daemon.enable = true;

	services.tailscale.enable = true;

	users.users.dimitar = {
		name = "dimitar";
		home = "/Users/dimitar";
	};

	system.stateVersion = 4;
}
