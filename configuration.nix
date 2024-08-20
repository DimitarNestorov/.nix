{
	pkgs,
	pkgs-aldente,
	pkgs-bartender,
	lib,
	...
}:
{
	nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.overlays = [
    (self: super: {
      aldente = pkgs-aldente.aldente;
      bartender = pkgs-bartender.bartender;
    })
  ];

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"Xcode.app"
		"google-chrome"
	];

	environment = {
		# List packages installed in system profile. To search by name, run:
		# $ nix-env -qaP | grep wget
		systemPackages = with pkgs; [
			# TODO: _1password-gui
			darwin.xcode_15_1
			google-chrome
			bartender
			aldente
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

	system.defaults = {
		NSGlobalDomain = {
			# Enables Keyboard -> Keyboard navigation
			AppleKeyboardUIMode = 3;
			# Sets Appearance -> Sidebar -> Sidebar icon size to "Large"
			NSTableViewDefaultSizeMode = 3;
			NSWindowResizeTime = 0.1;
			NSWindowShouldDragOnGesture = true;
			# Enables Sound -> Sound Effects -> Play feedback when volume is changed
			"com.apple.sound.beep.feedback" = 1;
			# Sets Trackpad -> Point & Click -> Tracking speed
			"com.apple.trackpad.scaling" = 0.875;
			# Enables Trackpad -> Point & Click -> Force Click and haptic feedback
			"com.apple.trackpad.forceClick" = true;
			# Enables Trackpad -> Scroll & Zoom -> Natural scrolling and Mouse -> Nautral scrolling
			"com.apple.swipescrolldirection" = true;
			# Sets Language & Region -> Measurement system to "Metric"
			AppleMeasurementUnits = "Centimeters";
			# Sets Language & Region -> Measurement system to "Metric"
			AppleMetricUnits = 1;
			# Sets Language & Region -> Temperature to "Celsius"
			AppleTemperatureUnit = "Celsius";
			# Disables Date & Time -> 24-hour time
			AppleICUForce24HourTime = false;
		};

		# Enables Control Center -> Menu Bar Only -> Clock Options… -> Display the time with seconds
		menuExtraClock.ShowSeconds = true;

		dock = {
			appswitcher-all-displays = true;
			# Enables Desktop & Dock -> Mission Control -> Group windows by application
			expose-group-by-app = true;
			# Disables Desktop & Dock -> Mission Control -> Automatically rearrange Spaces based on most recent use
			mru-spaces = false;
			# Disables Desktop & Dock -> Dock -> Show suggested and recent apps in Dock
			show-recents = false;
			# Sets Desktop & Dock -> Dock -> Size to Large
			tilesize = 128;
			persistent-apps = [
				"/System/Applications/Mail.app"
				"/System/Applications/Notes.app"
				"/System/Applications/Messages.app"
				"/System/Applications/Music.app"
				"/System/Cryptexes/App/System/Applications/Safari.app"
				"${pkgs.vscodium}/Applications/VSCodium.app"
				"${pkgs.darwin.xcode_15_1}"
				"${pkgs.darwin.xcode_15_1}/Contents/Developer/Applications/Simulator.app"
				"${pkgs.iterm2}/Applications/iTerm2.app"
				"${pkgs.google-chrome}/Applications/Google Chrome.app"
				"/System/Applications/Utilities/Screen Sharing.app"
				"/System/Applications/Launchpad.app"
			];
			persistent-others = [
				"/Users/dimitar/Downloads"
			];

			# Hot Corners
			wvous-tl-corner = 1; # Disabled
			wvous-tr-corner = 12; # Notification Center
			wvous-bl-corner = 10; # Put Display to Sleep
			wvous-br-corner = 14; # Quick Note
		};

		CustomUserPreferences = {
			"com.apple.dock" = {
				springboard-columns = 10;
				springboard-rows = 5;
			};
		};
	};

	system.stateVersion = 4;
}
