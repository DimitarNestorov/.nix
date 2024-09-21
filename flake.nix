{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nixpkgs-tailscale.url = "github:nixos/nixpkgs/eb19b36ec45caf14e9fe5026d3970d89c03ced69";
		nixpkgs-aldente.url = "github:nixos/nixpkgs/61348a945b0d5b3ac027dc0b5ed0283ff5050ac8";
		nixpkgs-bartender.url = "github:nixos/nixpkgs/ac7e26a5db2f21cee071b1194b6204056bdada9d";
		nixpkgs-vncviewer.url = "github:nixos/nixpkgs/43f616a7cc2ee6c755c2860b0e974c255c911a13";
		nixpkgs-iterm2.url = "github:nixos/nixpkgs/4088596b40e68be2d75fb9a4a9f55d4a20034637";
		nixpkgs-xcode.url = "github:nixos/nixpkgs/28f2f2a4f9723cf730e427952922755c2d552dfc";
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
