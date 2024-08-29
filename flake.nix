{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
		nixpkgs-tailscale.url = "github:nixos/nixpkgs/eb19b36ec45caf14e9fe5026d3970d89c03ced69";
		nixpkgs-aldente-bartender-iterm2.url = "github:nixos/nixpkgs/f6feef0cfa27d008111025be1359cd6b2db02b50";
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
		nixpkgs-tailscale,
		nixpkgs-aldente-bartender-iterm2,
		nix-index-database,
		home-manager,
		...
	} @ inputs: let
		darwinModules = [
			./configuration.nix

			home-manager.darwinModules.home-manager
			{
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.dimitar = import ./home.nix;
			}

			nix-index-database.darwinModules.nix-index
		];

		configuration = systemArg: darwin.lib.darwinSystem rec {
			system = systemArg;
			modules = darwinModules;
			specialArgs = {
				pkgs-tailscale = import nixpkgs-tailscale { inherit system; };

				pkgs-aldente-bartender-iterm2 = import nixpkgs-aldente-bartender-iterm2 {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-aldente-bartender-iterm2.lib.getName pkg) [
						"aldente"
						"bartender"
					];
				};
			};
		};
	in {
		darwinConfigurations."adonis" = configuration "aarch64-darwin";
		darwinConfigurations."jason" = configuration "aarch64-darwin";
		darwinConfigurations."helenus" = configuration "x86_64-darwin";
	};
}
