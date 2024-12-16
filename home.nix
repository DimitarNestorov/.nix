{ config, lib, pkgs, type ? "personal", ... }:
let
	iterm2-terminal-integration = pkgs.stdenv.mkDerivation {
		pname = "iterm2-terminal-integration";
		version = "0.0.1";

		src = pkgs.fetchurl {
			url = "https://iterm2.com/shell_integration/fish";
			sha256 = "sha256-29XvF/8KGd63NOAqWPoxODPQAMA8gNr+MIHFEqcKov4=";
		};

		unpackPhase = ''
			for srcFile in $src; do
				cp $srcFile $(stripHash $srcFile)
			done
		'';

		installPhase = ''
			outDir=$out/bin
			mkdir -p $outDir
			cp $src $outDir/iterm2_shell_integration.fish
		'';
	};
in {
	home.stateVersion = "24.05";

	home.packages = with pkgs; [
		grc
		iterm2-terminal-integration
		terminal-notifier
		nano
		devenv
		nix-tree
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
			code = "codium";
		};

		loginShellInit = ''
			source ${iterm2-terminal-integration}/bin/iterm2_shell_integration.fish
		'';

		plugins = with pkgs.fishPlugins; [
			{ name = "tide"; src = tide.src; }
			{ name = "grc"; src = grc.src; }
			{ name = "done"; src = done.src; }
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
		userEmail = if type == "work"
			then "dimitar.nestorov@callstack.com"
			else "8790386+dimitarnestorov@users.noreply.github.com";
		extraConfig = {
			core.editor = "/etc/profiles/per-user/dimitar/bin/nano";
			push.autoSetupRemote = true;
		};
	};

	programs.htop.enable = true;

	programs.vscode = {
		enable = true;
		package = if type == "work" then pkgs.vscode else pkgs.vscodium;
		mutableExtensionsDir = false;
		extensions = with pkgs.vscode-extensions; [
			jnoortheen.nix-ide
			mhutchie.git-graph
			mkhl.direnv
			esbenp.prettier-vscode
			mikestead.dotenv
			vscode-icons-team.vscode-icons
			bradlc.vscode-tailwindcss
			yoavbls.pretty-ts-errors
		] ++ (if type == "work" then [] else [
			ziglang.vscode-zig
		]);
		userSettings = {
			"direnv.path.executable" = "/etc/profiles/per-user/dimitar/bin/direnv";
			"editor.accessibilitySupport" = "off";
			"editor.defaultFormatter" = "esbenp.prettier-vscode";
			"editor.fontFamily" = "JetBrainsMono Nerd Font";
			"editor.fontLigatures" = true;
			"editor.fontSize" = 16;
			"editor.formatOnSave" = true;
			"editor.insertSpaces" = false;
			"editor.minimap.enabled" = false;
			"editor.wordWrap" = "on";
			"extensions.autoCheckUpdates" = false;
			"extensions.autoUpdate" = false;
			"files.autoSave" = "onFocusChange";
			"git.autofetch" = true;
			"git.path" = "/run/current-system/sw/bin/git";
			"prettier.semi" = false;
			"prettier.tabWidth" = 4;
			"prettier.trailingComma" = "all";
			"prettier.useTabs" = true;
			"terminal.integrated.defaultProfile.osx" = "fish";
			"terminal.integrated.fontSize" = 15;
			"terminal.integrated.lineHeight" = 1.1;
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
					"path" = "/etc/profiles/per-user/dimitar/bin/fish";
					"args" = ["-l"];
				};
			};
			"update.mode" = "none";
			"workbench.iconTheme" = "vscode-icons";
		} // (if type == "work" then {} else {
			"zig.path" = "${pkgs.zig}/bin/zig";
			"zig.zls.path" = "${pkgs.zls}/bin/zls";
			"zig.initialSetupDone" = true;
		});
		keybindings = [
			{
				key = "shift+cmd+g";
				command = "-workbench.action.terminal.findPrevious";
				when = "terminalFindFocused && terminalHasBeenCreated || terminalFindFocused && terminalProcessSupported || terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
			}
			{
				key = "shift+cmd+g";
				command = "-editor.action.previousMatchFindAction";
				when = "editorFocus";
			}
			{
				key = "shift+cmd+g";
				command = "workbench.view.scm";
				when = "workbench.scm.active";
			}
			{
				key = "ctrl+shift+g";
				command = "-workbench.view.scm";
				when = "workbench.scm.active";
			}
			{
				key = "ctrl+shift+-";
				command = "workbench.action.navigateBack";
			}
			{
				key = "ctrl+-";
				command = "-workbench.action.navigateBack";
			}
			{
				key = "ctrl+shift+-";
				command = "-workbench.action.navigateForward";
			}
		];
	};

	xdg.configFile = let
		fishSetVars = vals: pkgs.lib.foldlAttrs (acc: name: value: acc + "set -u ${name} ${toString value}\n") "" vals;
	in {
		"fish/conf.d/tide-vars.fish".text = fishSetVars (import ./tide-config.nix);

		"fish/conf.d/add-nix-paths.fish".text = let
			profiles = [
				"/etc/profiles/per-user/$USER" # Home Manager packages
				"/run/current-system/sw" # Nix Darwin packages
			];

			makeBinSearchPath = lib.concatMapStringsSep " " (path: "${path}/bin");
		in ''
			fish_add_path --move --prepend --path ${makeBinSearchPath profiles}
		'';
	};
}
