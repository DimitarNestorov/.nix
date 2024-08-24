{ config, lib, pkgs, ... }:
{
	home.stateVersion = "24.05";

	home.packages = with pkgs; [
		grc
	];

	programs.home-manager.enable = true;

	programs.direnv = {
		enable = true;

		nix-direnv.enable = true;
	};

	programs.fish = {
		enable = true;

		shellAliases = {
			darwin-rebuild-switch = "~/.nix/rebuild-and-switch.sh";
			ls = "colorls";
		};

		# https://github.com/LnL7/nix-darwin/issues/122#issuecomment-2272570087
		loginShellInit = let
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

			makeBinSearchPath = lib.concatMapStringsSep " " (path: "${path}/bin");
		in ''
			# Fix path that was re-ordered by Apple's path_helper
			fish_add_path --move --prepend --path ${makeBinSearchPath profiles}
			set fish_user_paths $fish_user_paths
		'';

    plugins = [
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
		];

		functions = {
			fish_greeting = {
				description = "Greeting to show when starting a fish shell";
				body = "";
			};
		};
	};
	
	programs.git = {
		enable = true;
		userName = "Dimitar Nestorov";
		userEmail = "8790386+dimitarnestorov@users.noreply.github.com";
		extraConfig = {
			push.autoSetupRemote = true;
		};
	};

	programs.vscode = {
		enable = true;
		package = pkgs.vscodium;
		extensions = with pkgs.vscode-extensions; [
			jnoortheen.nix-ide
			mhutchie.git-graph
			mkhl.direnv
		];
		userSettings = {
			"direnv.path.executable" = "/etc/profiles/per-user/dimitar/bin/direnv";
			"editor.wordWrap" = "on";
			"editor.minimap.enabled" = false;
			"extensions.autoCheckUpdates" = false;
			"extensions.autoUpdate" = false;
			"files.autoSave" = "onFocusChange";
			"git.autofetch" = true;
			"git.path" = "/run/current-system/sw/bin/git";
			"terminal.integrated.defaultProfile.osx" = "fish";
			"terminal.integrated.profiles.osx" = {
				"bash" = {
					"path" = "bash";
					"args" = ["-l"];
					"icon" = "terminal-bash";
				};
				"zsh" = {
					"path" = "zsh";
					"args" = ["-l"];
				};
				"fish" = {
					"path" = "/run/current-system/sw/bin/fish";
					"args" = ["-l"];
				};
			};
			"update.mode" = "none";
		};
	};
}
