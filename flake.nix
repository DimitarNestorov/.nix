{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nixpkgs-tailscale.url = "github:nixos/nixpkgs/eb19b36ec45caf14e9fe5026d3970d89c03ced69";
		nixpkgs-aldente.url = "github:nixos/nixpkgs/db7dd707e17ac5d317ef4fd7924ce8820532952c";
		nixpkgs-bartender.url = "github:DimitarNestorov/nixpkgs/a548595bb3a3822fd27f73aa7c8be79ea762303b";
		nixpkgs-vncviewer.url = "github:nixos/nixpkgs/43f616a7cc2ee6c755c2860b0e974c255c911a13";
		nixpkgs-iterm2.url = "github:nixos/nixpkgs/4088596b40e68be2d75fb9a4a9f55d4a20034637";
		nixpkgs-xcode.url = "github:nixos/nixpkgs/28f2f2a4f9723cf730e427952922755c2d552dfc";
		nixpkgs-sloth.url = "github:nixos/nixpkgs/2aee66095ca9cd6dfa78ca18ce79a1a5599e828c";
		nixpkgs-dbeaver.url = "github:nixos/nixpkgs/3c5a0228d9b4e6e233c22047d61ac6bd55e81661";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
		nix-index-database.url = "github:nix-community/nix-index-database";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.url = "github:nix-community/home-manager/release-24.05";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = {
		self,
		darwin,
		nixpkgs,
		nixpkgs-unstable,
		nixpkgs-tailscale,
		nixpkgs-aldente,
		nixpkgs-bartender,
		nixpkgs-vncviewer,
		nixpkgs-iterm2,
		nixpkgs-xcode,
		nixpkgs-sloth,
		nixpkgs-dbeaver,
		nix-index-database,
		home-manager,
		...
	} @ inputs: let
		darwinModules = [
			./configuration.nix
			home-manager.darwinModules.home-manager
			nix-index-database.darwinModules.nix-index
			{
				nix.registry = {
					nixpkgs.flake = nixpkgs;
					nixpkgs-unstable.flake = nixpkgs-unstable;
				};
			}
		];

		configuration = systemArg: darwin.lib.darwinSystem rec {
			system = systemArg;
			modules = darwinModules;
			specialArgs = {
				pkgs-tailscale = import nixpkgs-tailscale { inherit system; };

				pkgs-aldente = import nixpkgs-aldente {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-aldente.lib.getName pkg) [
						"aldente"
					];
				};

				pkgs-bartender = import nixpkgs-bartender {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-bartender.lib.getName pkg) [
						"bartender"
					];
				};

				pkgs-vncviewer = import nixpkgs-vncviewer {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-vncviewer.lib.getName pkg) [
						"realvnc-vnc-viewer"
					];
				};

				pkgs-iterm2 = import nixpkgs-iterm2 { inherit system; };

				pkgs-xcode = import nixpkgs-xcode {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-xcode.lib.getName pkg) [
						"Xcode.app"
					];
				};

				pkgs-sloth = import nixpkgs-sloth { inherit system; };
				pkgs-dbeaver = import nixpkgs-dbeaver { inherit system; };
			};
		};
	in {
		darwinConfigurations = {
			adonis = configuration "aarch64-darwin";
			jason = configuration "aarch64-darwin";
			helenus = configuration "x86_64-darwin";
		};
	};
}
