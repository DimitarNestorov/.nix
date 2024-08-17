{ config, pkgs, ... }:
{
	home.stateVersion = "24.05";

	programs.home-manager.enable = true;
	
	programs.git = {
		enable = true;
		userName = "Dimitar Nestorov";
		userEmail = "8790386+dimitarnestorov@users.noreply.github.com";
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
			"direnv.path.executable" = "/run/current-system/sw/bin/direnv";
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
