{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nixpkgs-tailscale.url = "github:nixos/nixpkgs/eb19b36ec45caf14e9fe5026d3970d89c03ced69";
		nixpkgs-aldente-bartender-iterm2.url = "github:nixos/nixpkgs/4088596b40e68be2d75fb9a4a9f55d4a20034637";
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

				nix.registry = {
					nixpkgs.flake = nixpkgs;
					nixpkgs-unstable.flake = nixpkgs-unstable;
				};
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
		darwinConfigurations = {
			adonis = configuration "aarch64-darwin";
			jason = configuration "aarch64-darwin";
			helenus = configuration "x86_64-darwin";
		};
	};
}
