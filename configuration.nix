{ pkgs, pkgs-xcode, lib, ... }:
let
	xcodePkg = pkgs-xcode.darwin.xcode_16;
in {
	nix.settings.experimental-features = "nix-command flakes";

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"google-chrome"
		"keka"
	];

	environment = {
		# List packages installed in system profile. To search by name, run:
		# $ nix-env -qaP | grep wget
		systemPackages = with pkgs; [
			# TODO: _1password-gui
			xcodePkg
			realvnc-vnc-viewer
			google-chrome
			keka
			bartender
			aldente
			vscodium
			git
			imgcat
			iterm2
			colorls
			iina
			tailscale
			localsend
			sloth-app
			dbeaver-bin
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

	home-manager = {
		useGlobalPkgs = true;
		useUserPackages = true;
		users.dimitar = import ./home.nix;
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
			# Sets Appearance -> Show scroll bars to "When scrolling"
			AppleShowScrollBars = "WhenScrolling";
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
				"${xcodePkg}"
				"${xcodePkg}/Contents/Developer/Applications/Simulator.app"
				"${pkgs.iterm2}/Applications/iTerm2.app"
				"${pkgs.google-chrome}/Applications/Google Chrome.app"
				"/System/Applications/Utilities/Screen Sharing.app"
				"/System/Applications/Launchpad.app"
			];

			# Hot Corners
			wvous-tl-corner = 1; # Disabled
			wvous-tr-corner = 12; # Notification Center
			wvous-bl-corner = 10; # Put Display to Sleep
			wvous-br-corner = 14; # Quick Note
		};

		universalaccess = {
			# It sets Accessibility -> Display -> Pointer -> Pointer size to 2.0
			mouseDriverCursorSize = 2.0;
			# Enables Accessibility -> Zoom -> Use scroll gesture with modifier keys to zoom
			closeViewScrollWheelToggle = true;
		};

		CustomUserPreferences = {
			NSGlobalDomain = {
				AppleLanguages = [
					"en-US"
					"bg-BG"
				];

				# Sets Language & Region -> First day of week to "Monday"
				AppleFirstWeekday = {
					gregorian = 2;
				};
			};

			"com.apple.AppleMultitouchTrackpad" = {
				# Enables Trackpad -> Point & Click -> Tap to click
				Clicking = 1;
				# Sets Accessibility -> Motor -> Pointer Control -> Mouse & Trackpad -> Trackpad Options -> Dragging style to "Three Finger Drag"
				TrackpadThreeFingerDrag = 1;
				TrackpadThreeFingerHorizSwipeGesture = 0;
				TrackpadThreeFingerTapGesture = 0;
				TrackpadThreeFingerVertSwipeGesture = 0;
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

				persistent-others = [
					{
						tile-data = {
							arrangement = 2; # Date Added
							displayas = 0; # Stack
							showas = 1; # Fan
							file-data = {
								_CFURLString = "file:///Users/dimitar/Downloads/";
								_CFURLStringType = 15;
							};
						};
						tile-type = "directory-tile";
					}
				];
			};

			"com.apple.universalaccess" = {
				cursorIsCustomized = 1;
				cursorFill = {
					alpha = 1;
					blue = 0;
					green = 0;
					red = 0;
				};
				# Sets Accessibility -> Display -> Pointer -> Pointer outline color to #BBBBFF
				cursorOutline = {
					alpha = 1;
					blue = 1;
					green = 187.0 / 255;
					red = 187.0 / 255;
				};

				# Enables Hover Text
				hoverTextActivationLockMode = 0;
				hoverTextBorderColor = {};
				hoverTextCustomBackgroundColor = {};
				hoverTextCustomCursorColor = {};
				hoverTextCustomFontColor = {};
				hoverTextElementHighlightColor = {};
				hoverTextEnabled = 1;
				hoverTextFontStyle = 1;
				hoverTextIsAlwaysOn = 0;
				hoverTextIsHoveringAndVisible = 0;
				hoverTextModifier = 1; # Changes modifier key to option
				hoverTextShowWhenTyping = 0;

				"com.apple.custommenu.apps" = [
					"com.apple.Safari"
					"com.apple.mail"
				];
			};

			"com.apple.Safari" = {
				NSUserKeyEquivalents = {
					Back = "^$-";
					"Undo Close Tab" = "@~^$[";
				};
			};

			"com.apple.mail" = {
				NSUserKeyEquivalents = {
					Delete = "@w";
				};
			};

			"com.apple.Safari" = {
				# Disables AutoFill -> AutoFill web forms -> Credit cards
				AutoFillCreditCardData = 0;
				# Disables AutoFill -> AutoFill web forms -> User names and passwords
				AutoFillPasswords = 0;
				# Enables Advanced -> Smart Search field -> Show full website address
				ShowFullURLInSmartSearchField = 1;

				IncludeDevelopMenu = 1;
				IncludeInternalDebugMenu = 1;
				WebKitDeveloperExtrasEnabledPreferenceKey = 1;
				"WebKitPreferences.developerExtrasEnabled" = 1;
			};

			"com.apple.Safari.SandboxBroker" = {
				ShowDevelopMenu = 1;
			};

			# App Store
			"com.apple.commerce" = {
				# Disables Automatic Updates
				AutoUpdate = false;
			};

			"com.apple.mail" = {
				NSFixedPitchFont = "JetBrainsMonoNF-Regular";
				NSFixedPitchFontSize = 14;
				NSFont = "Helvetica";
				NSFontSize = 14;
				"NSToolbar Configuration MainWindow" = {
					"TB Default Item Identifiers" = [
						"toggleMessageListFilter:"
						"SeparatorToolbarItem"
						"checkNewMail:"
						"showComposeWindow:"
						"NSToolbarFlexibleSpaceItem"
						"archive_delete_junk"
						"reply_replyAll_forward"
						"FlaggedStatus"
						"muteFromToolbar:"
						"moveMessagesFromToolbar:"
						"Search"
					];
					"TB Display Mode" = 2;
					"TB Icon Size Mode" = 1;
					"TB Is Shown" = 1;
					"TB Item Identifiers" = [
						"toggleMessageListFilter:"
						"SeparatorToolbarItem"
						"checkNewMail:"
						"showComposeWindow:"
						"NSToolbarFlexibleSpaceItem"
						"archive_delete_junk"
						"reply_replyAll_forward"
						"FlaggedStatus"
						"muteFromToolbar:"
						"moveMessagesFromToolbarExpanded:"
						"NSToolbarSpaceItem"
						"Search"
					];
					"TB Size Mode" = 1;
				};
			};
		};

		CustomSystemPreferences = {
			"/var/root/Library/Preferences/com.apple.CoreBrightness.plist" = let
				userId = builtins.readFile (pkgs.runCommand "user-id" {} "/usr/bin/dscl . -read /Users/dimitar GeneratedUID | /usr/bin/sed 's/GeneratedUID: //' | /usr/bin/tr -d \\\\n > $out");
			in {
				"CBUser-${userId}" = {
					CBBlueLightReductionCCTTargetRaw = "3433.05";
					CBBlueReductionStatus = {
						AutoBlueReductionEnabled = 1;
						BlueLightReductionAlgoOverride = 0;
						BlueLightReductionDisableScheduleAlertCounter = 3;
						BlueLightReductionSchedule = {
							DayStartHour = 7;
							DayStartMinute = 0;
							NightStartHour = 22;
							NightStartMinute = 0;
						};
						BlueReductionAvailable = 1;
						BlueReductionEnabled = 0;
						BlueReductionMode = 1;
						BlueReductionSunScheduleAllowed = 1;
						Version = 1;
					};
					CBColorAdaptationEnabled = 1;
				};
			};
		};
	};

	system.stateVersion = 4;
}
