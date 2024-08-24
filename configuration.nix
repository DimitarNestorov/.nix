{
	pkgs,
	pkgs-aldente-bartender,
	pkgs-iterm2,
	lib,
	...
}:
{
	nix.settings.experimental-features = "nix-command flakes";

	nixpkgs.overlays = [
		(self: super: {
			aldente = pkgs-aldente-bartender.aldente;
			bartender = pkgs-aldente-bartender.bartender;
			iterm2 = pkgs-iterm2.iterm2;
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
			imgcat
			iterm2
			colorls
			iina
			fish
			tailscale
		];
	};

	fonts = {
		packages = with pkgs; [
			(nerdfonts.override { fonts = ["JetBrainsMono"]; })
			(google-fonts.override { fonts = ["PublicSans"]; })
		];
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
			NSGlobalDomain = {
				AppleLanguages = [
					"en-US"
					"bg-BG"
				];
			};

			"com.apple.HIToolbox" = {
				AppleEnabledInputSources = [
					{
						InputSourceKind = "Keyboard Layout";
						"KeyboardLayout ID" = 0;
						"KeyboardLayout Name" = "U.S.";
					}
					{
						InputSourceKind = "Keyboard Layout";
						"KeyboardLayout ID" = 19529;
						"KeyboardLayout Name" = "Bulgarian - Phonetic";
					}
				];
			};

			"com.apple.dock" = {
				springboard-columns = 10;
				springboard-rows = 5;
			};
		};
	};

	system.stateVersion = 4;
}
