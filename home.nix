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
		];
		userSettings = {
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;
      "files.autoSave" = "onFocusChange";
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
      "terminal.integrated.defaultProfile.osx" = "fish";
      "git.path" = "/run/current-system/sw/bin/git";
      "git.autofetch" = true;
      "editor.wordWrap" = "on";
    };
	};
}
