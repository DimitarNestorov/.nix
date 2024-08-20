{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
		nixpkgs-aldente.url = "github:nixos/nixpkgs/629b012e04c93a5f653fc62060f2e0473ba74a0c";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
		nix-index-database.url = "github:nix-community/nix-index-database/838a910df0f7e542de2327036b2867fd68ded3a2";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.url = "github:nix-community/home-manager/release-24.05";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, darwin, nixpkgs, nixpkgs-aldente, nix-index-database, home-manager, ... }@inputs: 
	let
		darwinModules = [
			./configuration.nix

			home-manager.darwinModules.home-manager
			{
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.dimitar = import ./home.nix;
			}

			nix-index-database.nixosModules.nix-index
			{ nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ]; }
		];

		configuration = systemArg: darwin.lib.darwinSystem rec {
			system = systemArg;
			modules = darwinModules;
			specialArgs = {
				pkgs-aldente = import nixpkgs-aldente {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-aldente.lib.getName pkg) [
						"aldente"
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
